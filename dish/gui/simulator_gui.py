import os
import sys
import copy
import pandas as pd
import configparser
from py2cytoscape.data.cyrest_client import CyRestClient
from PyQt5.QtCore import QAbstractTableModel, Qt, QUrl
from PyQt5.QtWidgets import QApplication, QDialog, QFileDialog, QMainWindow, QInputDialog, QProgressBar, QSystemTrayIcon
from PyQt5.QtGui import QIcon, QPixmap, QImage, QImageReader
from PyQt5.uic import loadUi

from dish.model import get_model, model_to_excel, model_to_networkx
from dish.simulator import Simulator
from dish.visualization import get_traces, plot_average, save_plots

from MainWindow import Ui_MainWindow
from PlotWindow import Ui_PlotWindow


class DataFrameModel(QAbstractTableModel):
    """ Custom class for using pandas dataframe as Qt table model"""

    def __init__(self, data, parent=None):
        QAbstractTableModel.__init__(self, parent)
        self._data = data

    def rowCount(self, parent=None):
        return self._data.shape[0]

    def columnCount(self, parent=None):
        return self._data.shape[1]

    def data(self, index, role=Qt.DisplayRole):
        if index.isValid():
            if role == Qt.DisplayRole or role == Qt.EditRole:
                return str(self._data.iloc[index.row(), index.column()])
        return None

    def headerData(self, rowcol, orientation, role):
        if orientation == Qt.Horizontal and role == Qt.DisplayRole:
            return self._data.columns[rowcol]
        if orientation == Qt.Vertical and role == Qt.DisplayRole:
            return self._data.index[rowcol]
        return None

    def flags(self, index):
        if not index.isValid():
            return Qt.ItemIsEnabled
        return Qt.ItemFlags(QAbstractTableModel.flags(self,index) | Qt.ItemIsEditable)
        
    def setData(self, index, value, role=Qt.EditRole):
        if index.isValid() and 0 <= index.row() < self._data.shape[0]:
            self._data.iloc[index.row(), index.column()] = str(value)
            return True
        return False
        

class PlotWindow(QMainWindow):
    def __init__(self, parent=None):
        super(PlotWindow, self).__init__(parent)
        self.ui = Ui_PlotWindow()
        self.ui.setupUi(self)
        self.setFixedSize(self.size())

    def plot_element(self, plot_image, plot_title):
        self.setWindowTitle(plot_title)
        self.ui.lbl_plot.setPixmap(plot_image)
        self.ui.lbl_plot.setEnabled(True)

    
class MainWindow(QMainWindow):
    def __init__(self, config):
        super(MainWindow, self).__init__()

        # configuration parameters
        self.steps = config.getint('Settings', 'steps', fallback=100)
        self.runs = config.getint('Settings', 'runs', fallback=5)
        self.debug = config.getboolean('Settings', 'debug', fallback=False)

        # simulation scheme names and simulator input
        self.scheme_mapping = {'Random Sequential': 'ra',
					'Round-Based' : 'round',
                    'Simultaneous' : 'sync'}
        
        # instance variables for passing simulation parameters
        self.trace_files = []
        self.scenarios = []
        self.scheme = ''
        
        # set up GUI window
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.setFixedSize(self.size())

        # model table view
        self.ui.tv_influenceSet_view.verticalHeader().setMaximumWidth(int(self.ui.tv_influenceSet_view.width()/4))

        # connect control functions
        # model
        self.ui.btn_browseModelFile.clicked.connect(self.browse_model_file)
        self.ui.btn_saveModelFile.clicked.connect(self.save_model_file)
        self.ui.btn_exportGraph.clicked.connect(self.export_graph)
        self.ui.btn_closePlots.clicked.connect(self.close_windows)

        # simulation
        self.ui.btn_simulate.clicked.connect(self.run_simulation)
        self.ui.cb_scheme.currentTextChanged.connect(self.update_time_label)

        # plotting
        self.ui.btn_plot.clicked.connect(self.plot_element)

        # output
        self.ui.btn_saveOutputLog.clicked.connect(self.save_output_log)

        # set default values
        self.ui.sb_steps.setValue(self.steps)
        self.ui.sb_runs.setValue(self.runs)
        self.ui.cb_scheme.addItems(list(self.scheme_mapping.keys()))
        self.ui.chk_normalize.setChecked(True)

        # enable/disable controls
        self.set_export_controls(False)
        self.set_sim_controls(False, reset=True)
        self.set_plot_controls(False, reset=True)
        self.ui.btn_closePlots.setEnabled(False)

        # output console
        self.ui.btn_saveOutputLog.setEnabled(True)
        self.ui.tb_console.setEnabled(True)

    def set_export_controls(self, status):
        if status in [True, False]:
            self.ui.lbl_export.setEnabled(status)
            self.ui.lbl_export.repaint()
            self.ui.btn_saveModelFile.setEnabled(status)
            self.ui.btn_saveModelFile.repaint()
            self.ui.btn_exportGraph.setEnabled(status)
            self.ui.btn_exportGraph.repaint()

    def set_sim_controls(self, status, reset=False):
        if status in [True, False]:
            if reset:
                self.ui.lw_scenario.clear()
            self.ui.lbl_scheme.setEnabled(status)
            self.ui.lbl_scheme.repaint()
            self.ui.cb_scheme.setEnabled(status)
            self.ui.cb_scheme.repaint()
            self.ui.lbl_runs.setEnabled(status)
            self.ui.lbl_runs.repaint()
            self.ui.sb_runs.setEnabled(status)
            self.ui.sb_runs.repaint()
            self.ui.lbl_steps.setEnabled(status)
            self.ui.lbl_steps.repaint()
            self.ui.sb_steps.setEnabled(status)
            self.ui.sb_steps.repaint()
            self.ui.lbl_scenario.setEnabled(status)
            self.ui.lbl_scenario.repaint()
            self.ui.lw_scenario.setEnabled(status)
            self.ui.lw_scenario.repaint()
            self.ui.btn_simulate.setEnabled(status)
            self.ui.btn_simulate.repaint()
    
    def set_plot_controls(self, status, reset=False):
        if status in [True, False]:
            if reset:
                self.ui.cb_plotElement.clear()
                self.ui.lbl_plotting.setText('')
            self.ui.lbl_plotting.setEnabled(status)
            self.ui.lbl_plotting.repaint()
            self.ui.cb_plotElement.setEnabled(status)
            self.ui.cb_plotElement.repaint()
            self.ui.btn_plot.setEnabled(status)
            self.ui.btn_plot.repaint()
            self.ui.chk_normalize.setEnabled(status)
            self.ui.chk_normalize.repaint()

    def log(self, log_string):
        self.ui.tb_console.append(log_string)
        self.ui.tb_console.repaint()

    def save_output_log(self):
        
        try:
            save_output_log_file = QFileDialog.getSaveFileName(self, 'Save Output Log As',
                    filter='Text Files (*.txt)',
                    options=QFileDialog.DontUseNativeDialog)
            
            if (save_output_log_file[0] != ''):
                output_log_file = save_output_log_file[0]
                if os.path.splitext(output_log_file)[1] != '.txt':
                    self.log('Warning: Corrected file extension to .txt')
                    output_log_file = f'{os.path.splitext(output_log_file)[0]}.txt'

                output_log = self.ui.tb_console.toPlainText()
                with open(output_log_file, 'w') as log_file:
                    log_file.write(output_log)
                
                log_base_name = os.path.basename(output_log_file)
                self.log(f'Saved output as: {log_base_name}')

        except Exception as save_output_err:
            self.log('Error: Output save failed')
            if self.debug:
                self.log(str(save_output_err.args))
    
    def close_windows(self):
        plot_windows = self.findChildren(QMainWindow)
        [window.close() for window in plot_windows]
        self.log('Closed all plot windows')
        self.ui.btn_closePlots.setEnabled(False)
        self.ui.btn_closePlots.repaint()

    def load_model(self, model_filename):

        try:
            model_df_input = get_model(model_filename)
            model = DataFrameModel(model_df_input)
            
            return model
        
        except Exception as load_model_err:
            self.log('Error: Model load failed')
            if self.debug:
                self.log(str(load_model_err.args))

    def get_scenarios(self):

        model_df = self.ui.tv_influenceSet_view.model()._data

        scenarios = [x.strip() for x in model_df.columns if ('initial' in x.lower() or 'scenario' in x.lower())]
        
        return scenarios
    
    def get_elements(self):
        
        model_df = self.ui.tv_influenceSet_view.model()._data

        elements = list(model_df.index)

        return elements
        
    def browse_model_file(self):

        try:
            input_file = QFileDialog.getOpenFileName(self, 'Select Model File',
                    filter='Excel Files (*.xlsx *.xls)',
                    options=QFileDialog.DontUseNativeDialog)

            if input_file[0] != '':
                input_filename = input_file[0]

                initial_read = pd.read_excel(input_filename)
                if 'Variable' in initial_read.columns:
                    model = self.load_model(input_filename)
                    log_msg = 'Loaded model'
                else:
                    model = None
                    log_msg = 'Error: Incorrect model format'
                
                if model is not None:
                    update = self.update_model_view(model)

                    if update is None:
                        raise ValueError('View update failed')

                    input_basename = os.path.basename(input_filename)
                    self.log(f'{log_msg}: {input_basename}')

        except Exception as browse_model_err:
            self.log('Error: Model load failed')
            if self.debug:
                self.log(str(browse_model_err.args))

    def update_model_view(self, model):

        try:
            
            # load model to display in table view
            self.ui.tv_influenceSet_view.setModel(model)

            # reset controls
            self.set_sim_controls(False, reset=True)
            self.set_plot_controls(False, reset=True)
            
            # get scenarios
            scenarios = self.get_scenarios()
            self.ui.lw_scenario.addItems(scenarios)
            self.ui.lw_scenario.item(0).setSelected(True)

            # get elements for property controls
            elements = self.get_elements()

            # enable controls
            self.set_export_controls(True)
            self.set_sim_controls(True)
            self.ui.tb_console.setEnabled(True)

            return True
        
        except Exception as update_view_err:
            self.log('Error: Model view update failed')
            self.ui.tv_influenceSet_view.setModel(None)

            if self.debug:
                self.log(str(update_view_err.args))
            
            return None


    def save_model_file(self):
        """Save table view model object to file"""

        try:
            save_model_file = QFileDialog.getSaveFileName(self, 'Save Model As',
                    filter='Excel Files (*.xlsx *.xls)',
                    options=QFileDialog.DontUseNativeDialog)

            if (save_model_file[0] != ''):
                self.save_model(save_model_file[0])

                base_file_name = os.path.basename(save_model_file[0])
                self.log(f'Saved model as: {base_file_name}')

        except Exception as save_model_err:
            self.log('Error: Model save failed')
            if self.debug:
                self.log(str(save_model_err.args))


    def export_graph(self):
        """Convert model to cytoscape graph and display in cytoscape"""
        
        try:
            model_df = copy.deepcopy(self.ui.tv_influenceSet_view.model()._data)
            model_graph = model_to_networkx(model_df)
        except Exception as model_graph_err:
            self.log('Error: Model graph conversion failed')

        # setup call to cytoscape
        try:
            cy = CyRestClient()
            cy_network = cy.network.create_from_networkx(model_graph)
            cy.style.apply(cy.style.create('default'), cy_network)
            cy.layout.apply(name='hierarchical', network=cy_network)

            self.log('Model graph exported to Cytoscape')

        except Exception as cyerr:
            self.log('Error: Cytoscape export failed, check that Cytoscape is open')
            if self.debug:
                self.log(str(cyerr.args))

    def update_time_label(self):
        if self.ui.cb_scheme.currentText() == 'Round-Based':
            self.ui.lbl_steps.setText('Rounds')
            self.ui.lbl_steps.repaint()
        else:
            self.ui.lbl_steps.setText('Steps')
            self.ui.lbl_steps.repaint()

    def get_sim_params(self):
        """Get simulation parameters from controls"""

        scenarios = []
        
        try:
            steps = int(self.ui.sb_steps.value())
            runs = int(self.ui.sb_runs.value())
            scenarios = [int(self.ui.lw_scenario.row(x)) for x in self.ui.lw_scenario.selectedItems()]
            scheme = self.ui.cb_scheme.currentText()

            if len(scenarios) == 0:
                self.log('Select at least one scenario')
                return None, None, None, None

            else:

                scenarios_sorted = [str(x) for x in sorted(scenarios)]
                
                return steps, runs, scenarios_sorted, scheme

        except Exception as sim_params_err:
            self.log('Error: Failed to get simulation parameters')
            if self.debug:
                self.log(str(sim_params_err.args))

            return None, None, None, None


    def run_simulation(self):

        try:
            # get input parameter values
            steps, runs, scenarios, scheme = self.get_sim_params()

            # define default trace file
            if not os.path.exists('simulation'):
                os.mkdir('simulation')
            output_basename = os.path.join(os.getcwd(), 'simulation', 'output')

            if len(scenarios) > 1:
                trace_files = [f'{output_basename}_{this_scenario}.txt' for this_scenario in scenarios]
            else:
                trace_files = [f'{output_basename}.txt']
                
            if len(trace_files) > 0 and len(scenarios) > 0:

                self.trace_files = trace_files
                self.steps = steps
                self.runs = runs
                self.scenarios = scenarios
                self.scheme = scheme

                sim_scheme = self.scheme_mapping[self.scheme]
                
                # save temp model file from table view
                model_file = self.save_model()

                # instantiate simulator and run simulation
                model = Simulator(model_file)

                if len(scenarios) > 1:
                    # append the scenario index to the end of each file name
                    for this_scenario in scenarios:
                        this_output_filename = f'{output_basename}_{this_scenario}.txt'
                        model.run_simulation(sim_scheme, runs, steps, this_output_filename, int(this_scenario), outMode=3)
                        self.log(f'Simulation scenario {this_scenario} complete')
                else:
                    this_output_filename = f'{output_basename}.txt'
                    model.run_simulation(sim_scheme, runs, steps, this_output_filename, int(scenarios[0]), outMode=3)
                    self.log(f'Simulation scenario {scenarios[0]} complete')

                # remove temp model file
                os.remove(model_file)

                if self.scheme == 'Round-Based':
                    steps_str = f'\tRounds: {steps}'
                else:
                    steps_str = f'\tSteps: {steps}'


                self.log(f'Simulation Completed: \n'
                        f'\tScenario(s): {", ".join([str(s) for s in scenarios])} \n'
                        f'\tScheme: {scheme}\n'
                        f'{steps_str} \n'
                        f'\tRuns: {runs} ')
                
                self.update_plot_elements()

        except Exception as run_sim_err:
            self.log('Error: Simulation failed')
            if self.debug:
                self.log(str(run_sim_err.args))
    
    def update_plot_elements(self):
        
        try:
            # get model elements to add to plotting list
            self.ui.cb_plotElement.clear()
            elements = self.get_elements()
            self.ui.cb_plotElement.addItems(elements)

            if len(self.scenarios) > 1:
                scenario_str = f'Scenarios {",".join(self.scenarios)}'
            else:
                scenario_str = f'Scenario {self.scenarios[0]}'

            if self.scheme == 'Round-Based':
                steps_str = f'{self.steps} rounds'
            else:
                steps_str = f'{self.steps} steps'
            self.ui.lbl_plotting.setText(
                    f'Plotting: {scenario_str}, {steps_str}, {self.runs} runs')
            self.ui.lbl_plotting.repaint()

            self.set_plot_controls(True)
        
        except Exception as update_sim_view_err:
            self.log('Error: Plot elements update failed')
            if self.debug:
                self.log(str(update_sim_view_err.args))

    def plot_element(self):

        try:
            # Get simulation parameter values
            trace_files = self.trace_files
            plots_folder = os.path.dirname(trace_files[0])
            scenarios = self.scenarios
            plot_element = self.ui.cb_plotElement.currentText()
            normalize = self.ui.chk_normalize.isChecked()
            scheme = self.scheme

            if len(trace_files) > 0 and plot_element != '':

                # get scenario labels
                scenario_labels = [self.ui.lw_scenario.item(int(this_scenario)).text() for this_scenario in scenarios]
                traces_list = [get_traces(this_trace_file) for this_trace_file in trace_files]

                if normalize:
                    y_label = 'Level [%]'
                else:
                    y_label = 'Level'

                # plot
                avg_plots = plot_average(traces_list, [plot_element], normalize, scenario_labels,
                        y_label=y_label, x_label='Time')
                save_plots(avg_plots, plots_folder)

                # get and size plot image
                plot_image_file = os.path.join(plots_folder, f'{plot_element}.png')
                plot_image_pixmap = QPixmap(QImage(QImageReader(plot_image_file).read()))

                # open plot in a new window
                if len(scenario_labels) > 1:
                    plot_info = f'{scheme} scheme'
                else:
                    plot_info = f'Scenario: {scenario_labels[0]}, {scheme} scheme'

                plot_window = PlotWindow(self)
                plot_window.plot_element(plot_image_pixmap, plot_info)
                plot_window.show()

                self.ui.btn_closePlots.setEnabled(True)
                self.ui.btn_closePlots.repaint()

                self.log(f'Plotted element: {plot_element}')

        except Exception as plot_err:
            self.log('Error: Plotting failed')
            if self.debug:
                self.log(str(plot_err.args))


    def save_model(self, model_file='~temp_model.xlsx'):

        try:
            # save temp model file from table view
            if os.path.splitext(model_file)[1] != '.xlsx':
                self.log('Warning: Corrected file extension to .xlsx')
                model_file = f'{os.path.splitext(model_file)[0]}.xlsx'

            model_file = os.path.join(os.getcwd(), model_file)
            model_df = copy.deepcopy(self.ui.tv_influenceSet_view.model()._data)

            model_to_excel(model_df, model_file)

            return model_file

        except Exception as temp_model_err:
            self.log('Error: Model save failed')
            if self.debug:
                self.log(str(temp_model_err.args))

            return None


if __name__ == '__main__':
    app = QApplication(sys.argv)

    # get system resolution for window positioning
    desktop = QApplication.desktop()
    resolution = desktop.availableGeometry()

    # get config from file
    config_file = os.path.join(os.getcwd(), 'config.ini')
    config = configparser.ConfigParser()

    if os.path.exists(config_file):
        config.read(config_file)

    window = MainWindow(config)
    window.show()
    window.move(resolution.center() - window.rect().center())
    sys.exit(app.exec_())
