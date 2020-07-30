from setuptools import setup

def readme():
    with open('README.md') as f:
        return f.read()

setup(
    name='dish',
    version='2.0',
    author='MeLoDy Lab',
    description='Discrete Stochastic Heterogeneous Simulator',
    long_description='Built by the Mechanisms and Logic of Dynamics Lab at the University of Pittsburgh',
    keywords='dynamic discrete qualitative modeling simulation',
    packages=[
        'dish',
    ],
    include_package_data=True,
    install_requires=[
        'matplotlib',
        'networkx',
        'numpy',
        'pandas',
        'xlrd',
        'py2cytoscape',
        'PyQt5',
        'seaborn'
    ],
    zip_safe=False # install as directory
    )