# DiSH Simulator

Discrete Stochastic Heterogeneous simulator, developed by the MeLoDy Lab at the University of Pittsburgh.

For theory and explanations of simulation schemes, see the original DiSH publication:

Khaled Sayed, Yu-Hsin Kuo, Anuva Kulkarni, and Natasa Miskov-Zivanov, "DiSH simulator: Capturing dynamics of cellular signaling with heterogeneous knowledge," in 2017 Winter Simulation Conference (WSC), 2017, pp. 896-907.

For explanation of the model tabular format, see the publication:

Khaled Sayed, Cheryl A. Telmer, Adam A. Butchy, and Natasa Miskov-Zivanov, "Recipes for Translating Big Data Machine Reading to Executable Cellular Signaling Models," in Machine Learning, Optimization, and Big Data, 2018, pp. 1-15.

## Installation

From inside the `dish/` directory, run:

~~~shell
pip install .
~~~

## Usage

DiSH GUI:

~~~shell
python gui/simulator_gui.py
~~~

Python scripting:

~~~Python
from dish.simulator import Simulator
from dish.visualization import get_traces, plot_average

model_file = 'examples/example_model_Tcell.xlsx'
scheme = 'ra' # Random Sequential
steps = 1000
runs = 100
output_file = 'examples/traces.txt'

model = Simulator(model_file)
model.run_simulation(scheme, runs, steps, output_file)

traces = get_traces(output_file)
plot_elements = ['TCR_HIGH','FOXP3','IL2']
plots = plot_average([traces], plot_elements)

~~~

## Model Format

Example model: `examples/models/example_model_Tcell.xlsx`

Required columns:

- __Variable__ : unique identifier
    - only letters, numbers, and underscores
    - must not start with a number
- __Element Name__ : descriptive name 
- __Element IDs__ : alternate names
- __Element Type__ 
- __Positive Regulators__, __Negative Regulators__
    - use influence set notation:
        - `A, B` : discrete OR
            - A OR B, which is max(A,B) for discrete variables
        - `(A, B)` : discrete AND 
            - A AND B, which is min(A,B) for discrete variables
        - `!A` : discrete NOT
            - uses n's complement
        - `A + B` : summation
        - `2*A` : weight (can be combined with summation)
        - `{A}[B]` : necessary pair 
            - A itself is sufficient for regulating X, while B can only strengthen the regulation when A is present
            - A and B can be expressions
            - the score is calculated as follows: 
                - If weights are included within {} or [], and some element within {} is nonzero, the score is calculated by summation: sum(A) + sum(B) 
                - If weights are not included, and some element within {} is nonzero, the score is calculated as: max(min(A),max(B)) 
                - If all elements within {} are zero, the score is 0
        - `A^` : Highest-value regulator 
            - A only has an effect if A is at its highest value
            - the score is either 0 or the maximum value
        - `A=1` : Target-value regulator
            - A only has an effect if A is at the target value (e.g., A=0 means A will only have an effect if A's value is 0)
            - the score is either 0 or the maximum value
        - `{A}` : Initializer 
            - xuppose we are updating variable X, and A is the initializer; if X is 0, then A must be >0 for X to be activated by any regulator
        - NOTE: Mixed OR and summation is not valid
- __Scenario__
    - initial values or toggle notation
    - can have multiple columns, each must include the word "Scenario" 
    - encode a toggle with bracket notation, for example `0,1[300]` specifies toggling from 0 to 1 at step 300
    - randomize with input 'r' or 'random'

Optional columns:

- __Levels__
    - number of discrete variable levels for that element (default 3)
- __Spontaneous__
    - spontaneous behavior for elements with either no positive or no negative regulators
    - input as an integer specifying delay in spontaneous behavior: "0" specifies spontaneous behavior with no delay
    - input "None" for no spontaneous behavior
        - WARNING! this will mean that an element has no way of returning to 0 if it has only positive regulators, for example
    - if a value is input but the element has both positive and negative regulators, there will be no spontaneous effect
- __Balancing__
    - specifies what happens when positive and negative regulation scores are equal, with optional delay
    - "decrease,0" is the default (if the column is left blank), and specifies a decrease with 0 delay
    - input "None" for no balancing behavior
- __Update Group__
    - elements in the same group will be updated in the same simulation step
- __Update Rate__
    - for Random Sequential simulation
    - elements with higher update rate values will be updated at a greater rate than those with lower values
    - input must be an integer
    - update probability scales linearly with update rate value. Elements with update rate value of 4 are 4 times as likely to be run as elements with update rate value of 1  and twice as likely to be run as elements with update rate value of 2
    - elements of unspecified update rate values are assumed to have an update rate of 1
- __Update Rank__
    - for Round-Based simulation
    - elements with higher update rank will be run before elements with lower update rank
    - input must be an integer
    - elements of unspecified update rank values will be assigned one of 0
- __Delay__
    - state transition delays in the format delay01,delay12,delay21,delay10 for 3 states (e.g., 1,1,1,1)
        - if only one delay is listed it will be used for all state transitions
        - leave blank for no delays    

