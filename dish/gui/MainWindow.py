# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'MainWindow.ui'
#
# Created by: PyQt5 UI code generator 5.15.0
#
# WARNING: Any manual changes made to this file will be lost when pyuic5 is
# run again.  Do not edit this file unless you know what you are doing.


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1062, 691)
        MainWindow.setToolButtonStyle(QtCore.Qt.ToolButtonIconOnly)
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.tv_influenceSet_view = QtWidgets.QTableView(self.centralwidget)
        self.tv_influenceSet_view.setGeometry(QtCore.QRect(20, 50, 1021, 371))
        self.tv_influenceSet_view.setEditTriggers(QtWidgets.QAbstractItemView.AnyKeyPressed|QtWidgets.QAbstractItemView.DoubleClicked|QtWidgets.QAbstractItemView.EditKeyPressed)
        self.tv_influenceSet_view.setAlternatingRowColors(True)
        self.tv_influenceSet_view.setObjectName("tv_influenceSet_view")
        self.tv_influenceSet_view.verticalHeader().setVisible(True)
        self.tv_influenceSet_view.verticalHeader().setCascadingSectionResizes(False)
        self.btn_exportGraph = QtWidgets.QPushButton(self.centralwidget)
        self.btn_exportGraph.setGeometry(QtCore.QRect(370, 10, 91, 41))
        self.btn_exportGraph.setDefault(False)
        self.btn_exportGraph.setFlat(False)
        self.btn_exportGraph.setObjectName("btn_exportGraph")
        self.btn_saveModelFile = QtWidgets.QPushButton(self.centralwidget)
        self.btn_saveModelFile.setGeometry(QtCore.QRect(270, 10, 91, 41))
        self.btn_saveModelFile.setObjectName("btn_saveModelFile")
        self.btn_browseModelFile = QtWidgets.QPushButton(self.centralwidget)
        self.btn_browseModelFile.setGeometry(QtCore.QRect(80, 10, 91, 41))
        self.btn_browseModelFile.setObjectName("btn_browseModelFile")
        self.tb_console = QtWidgets.QTextBrowser(self.centralwidget)
        self.tb_console.setGeometry(QtCore.QRect(20, 430, 601, 221))
        self.tb_console.setObjectName("tb_console")
        self.lbl_export = QtWidgets.QLabel(self.centralwidget)
        self.lbl_export.setGeometry(QtCore.QRect(220, 20, 51, 16))
        self.lbl_export.setAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.lbl_export.setObjectName("lbl_export")
        self.btn_saveOutputLog = QtWidgets.QPushButton(self.centralwidget)
        self.btn_saveOutputLog.setGeometry(QtCore.QRect(20, 650, 121, 31))
        self.btn_saveOutputLog.setObjectName("btn_saveOutputLog")
        self.lbl_scenario = QtWidgets.QLabel(self.centralwidget)
        self.lbl_scenario.setGeometry(QtCore.QRect(830, 430, 71, 16))
        self.lbl_scenario.setObjectName("lbl_scenario")
        self.lbl_runs = QtWidgets.QLabel(self.centralwidget)
        self.lbl_runs.setGeometry(QtCore.QRect(740, 430, 71, 16))
        self.lbl_runs.setAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.lbl_runs.setObjectName("lbl_runs")
        self.lbl_steps = QtWidgets.QLabel(self.centralwidget)
        self.lbl_steps.setGeometry(QtCore.QRect(640, 430, 91, 16))
        self.lbl_steps.setAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.lbl_steps.setObjectName("lbl_steps")
        self.chk_normalize = QtWidgets.QCheckBox(self.centralwidget)
        self.chk_normalize.setGeometry(QtCore.QRect(910, 610, 131, 20))
        self.chk_normalize.setChecked(False)
        self.chk_normalize.setObjectName("chk_normalize")
        self.btn_simulate = QtWidgets.QPushButton(self.centralwidget)
        self.btn_simulate.setGeometry(QtCore.QRect(640, 530, 171, 41))
        self.btn_simulate.setObjectName("btn_simulate")
        self.lw_scenario = QtWidgets.QListWidget(self.centralwidget)
        self.lw_scenario.setGeometry(QtCore.QRect(830, 450, 211, 111))
        self.lw_scenario.setVerticalScrollBarPolicy(QtCore.Qt.ScrollBarAsNeeded)
        self.lw_scenario.setSelectionMode(QtWidgets.QAbstractItemView.MultiSelection)
        self.lw_scenario.setResizeMode(QtWidgets.QListView.Adjust)
        self.lw_scenario.setObjectName("lw_scenario")
        self.cb_scheme = QtWidgets.QComboBox(self.centralwidget)
        self.cb_scheme.setGeometry(QtCore.QRect(640, 500, 181, 26))
        self.cb_scheme.setCurrentText("")
        self.cb_scheme.setObjectName("cb_scheme")
        self.sb_runs = QtWidgets.QSpinBox(self.centralwidget)
        self.sb_runs.setGeometry(QtCore.QRect(740, 450, 70, 24))
        self.sb_runs.setMinimum(1)
        self.sb_runs.setMaximum(10000)
        self.sb_runs.setSingleStep(10)
        self.sb_runs.setProperty("value", 100)
        self.sb_runs.setObjectName("sb_runs")
        self.cb_plotElement = QtWidgets.QComboBox(self.centralwidget)
        self.cb_plotElement.setGeometry(QtCore.QRect(640, 610, 261, 26))
        self.cb_plotElement.setInsertPolicy(QtWidgets.QComboBox.InsertAlphabetically)
        self.cb_plotElement.setObjectName("cb_plotElement")
        self.sb_steps = QtWidgets.QSpinBox(self.centralwidget)
        self.sb_steps.setGeometry(QtCore.QRect(640, 450, 70, 24))
        self.sb_steps.setMinimum(1)
        self.sb_steps.setMaximum(50000)
        self.sb_steps.setSingleStep(100)
        self.sb_steps.setProperty("value", 500)
        self.sb_steps.setObjectName("sb_steps")
        self.btn_plot = QtWidgets.QPushButton(self.centralwidget)
        self.btn_plot.setGeometry(QtCore.QRect(640, 640, 171, 41))
        self.btn_plot.setObjectName("btn_plot")
        self.lbl_import = QtWidgets.QLabel(self.centralwidget)
        self.lbl_import.setGeometry(QtCore.QRect(30, 20, 51, 16))
        self.lbl_import.setAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.lbl_import.setObjectName("lbl_import")
        self.btn_closePlots = QtWidgets.QPushButton(self.centralwidget)
        self.btn_closePlots.setGeometry(QtCore.QRect(930, 650, 121, 31))
        self.btn_closePlots.setObjectName("btn_closePlots")
        self.lbl_plotting = QtWidgets.QLabel(self.centralwidget)
        self.lbl_plotting.setGeometry(QtCore.QRect(640, 590, 411, 16))
        self.lbl_plotting.setText("")
        self.lbl_plotting.setAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.lbl_plotting.setObjectName("lbl_plotting")
        self.lbl_scheme = QtWidgets.QLabel(self.centralwidget)
        self.lbl_scheme.setGeometry(QtCore.QRect(640, 480, 71, 16))
        self.lbl_scheme.setAlignment(QtCore.Qt.AlignLeading|QtCore.Qt.AlignLeft|QtCore.Qt.AlignVCenter)
        self.lbl_scheme.setObjectName("lbl_scheme")
        MainWindow.setCentralWidget(self.centralwidget)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "DiSH"))
        self.btn_exportGraph.setText(_translate("MainWindow", "Graph"))
        self.btn_saveModelFile.setText(_translate("MainWindow", "Excel"))
        self.btn_browseModelFile.setText(_translate("MainWindow", "Model"))
        self.lbl_export.setText(_translate("MainWindow", "Export"))
        self.btn_saveOutputLog.setText(_translate("MainWindow", "Export Log"))
        self.lbl_scenario.setText(_translate("MainWindow", "Scenario(s)"))
        self.lbl_runs.setText(_translate("MainWindow", "Runs"))
        self.lbl_steps.setText(_translate("MainWindow", "Steps"))
        self.chk_normalize.setText(_translate("MainWindow", "Normalize Levels"))
        self.btn_simulate.setText(_translate("MainWindow", "Simulate"))
        self.btn_plot.setText(_translate("MainWindow", "Plot"))
        self.lbl_import.setText(_translate("MainWindow", "Import"))
        self.btn_closePlots.setText(_translate("MainWindow", "Close All Plots"))
        self.lbl_scheme.setText(_translate("MainWindow", "Scheme"))
