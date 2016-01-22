"""
Class module for controlling and interogating FVS using the Python variant 
modules compiled with Open-FVS.

Created on Nov 29, 2014

@author: tod.haren@gmail.com
"""

import os
import sys
import logging
import logging.config
import random
import importlib

#sys.path.append(os.path.abspath(os.path.dirname(__file__) + '/' + '..'))

import pyfvs

# FIXME: This is a hack for PyDev scripting
# os.chdir(os.path.split(__file__)[0])

pyfvs.init_logging()
log = logging.getLogger('pyfvs.fvs')

class FVS(object):
    """
    Provides an abstraction layer and convenience methods for running FVS.
    
    Access to the FVS API routines as well as additional FVS core routines,
        and common arrays and variables are accessible using standard Python
        attribute access conventions, eg. cycles = fvs.contrl.ncyc to find out
        how many projection cycles were executed. API and other subroutines 
        have expected input variables and return numpy arrays or Python objects.
    
    See the auto-generated HTML help file provided with each variant library 
        for a complete list of available subroutines and common variables.
    
    * NOTE: The FVS subroutines, etc. are all converted to lower case by F2PY.
    
    Basic usage:
    fvs = FVS(<variant abbreviation>)
    fvs.run_fvs(<path to keyword file>)
    
    # Return a tuple of species codes given an FVS ID using the FVS API.
    spp_attrs = fvs.fvsspeciescode(16)
    
    TODO: Add methods for execution with the start/stop routines.
    TODO: Add methods to collect tree attribute arrays.
    """
    def __init__(self, variant, stochastic=False, config=pyfvs.get_config()):
        """
        Initialize a FVS variant library.
        
        @param variant: FVS variant abbreviation, PN, WC, etc.
        @param stochastic: If True the FVS random number generater will be
                        reseeded on each call to run_fvs. If False the 
                        generator will be set to a fixed value of 1.0
        @param config:
        """
        self.variant = variant
        self.stochastic = stochastic
        self.config = config

        if not self.stochastic:
            self._random_seed = 12345.0

        self.fvslib_path = None
        self._load_fvslib()

    def _load_fvslib(self):
        """
        Load the requested FVS variant library.
        """

        variant_ext = 'pyfvs.pyfvs%sc' % self.variant.lower()[:2]
        try:
            self.fvslib = importlib.import_module(variant_ext)
        
        except ImportError:
            log.error('No library found for variant {}.'.format(self.variant))
            raise
            
        except:
            raise
            
        log.debug('Loaded FVS variant {} library from {}'.format(
                self.variant, self.fvslib.__file__))

        # Initialize the FVS parameters and arrays
        # FIXME: This api function is subject to change
        self.fvslib.fvs_step.init_blkdata()

    def __getattr__(self, attr):
        """
        Return an attribute from self.fvslib if it is n ot defined locally.
        """
        
        try:
            return getattr(self.fvslib, attr)
        
        except AttributeError:
            msg = 'No FVS object {}.'.format(attr,)
            log.exception(msg)
            raise AttributeError(msg)

    def set_random_seed(self, seed=None):
        """
        Reseed the FVS random number generator.  If seed is provided it will
        be used as the seed, otherwise a random number will be used.
        
        Args
        ----
        @param seed: None, or a number to seed the random number generator with. 
        """
        
        if seed is None:
            seed = random.random()

        self.ransed(True, seed)

    def _init_fvs(self, keywords):
        """
        Initialize FVS with the given keywords file.
        
        Args
        ----
        @param keywords: Path of the keyword file initialize FVS with.
        """
        
        if not os.path.exists(keywords):
            msg = 'The specified keyword file does not exist: {}'.format(keywords)
            log.error(msg)
            raise ValueError(msg)

        self.keywords = keywords
        self.fvslib.fvssetcmdline('--keywordfile={}'.format(keywords))

    def xrun_fvs(self, keywords):
        """
        Execute an FVS run for the given keyword file and return the error code.
        
        Args
        ----
        @param keywords: Path of the keyword file initialize FVS with.
        """
        self._init_fvs(keywords)

        if self.stochastic:
            self.set_random_seed()
            
        else:
            self.set_random_seed(self._random_seed)

        r = self.fvslib.fvs()
        if r == 1:
            msg = 'FVS returned error code {}.'.format(r)
            log.error(msg)
            raise IOError(msg)

        if r != 0 and r <= 10:
            log.warning('FVS return with error code {}.'.format(r))

        if r > 10:
            log.error('FVS encountered an error, {}'.format(r))

        return r

    def run_fvs(self, keywords):
        """
        Execute an FVS run for the given keyword file and return the error code.
        
        Args
        ----
        @param keywords: Path of the keyword file initialize FVS with.
        """

        if not os.path.exists(keywords):
            msg = 'The keyword file does not exist: {}'.format(keywords)
            log.error(msg)
            raise ValueError(msg)

        self.fvs_step.fvs_init(keywords)

        if self.stochastic:
            self.set_random_seed()
        else:
            self.set_random_seed(self._random_seed)

        # Loop through all growth cycles
        nc = self.num_cycles
        for n in range(nc):
            self.fvs_step.fvs_grow()

        # Finalize the projection
        r = self.fvs_step.fvs_end()

        if r == 1:
            msg = 'FVS returned error code {}.'.format(r)
            log.error(msg)
            raise IOError(msg)

        if r != 0 and r <= 10:
            log.warning('FVS return with error code {}.'.format(r))

        if r > 10:
            log.error('FVS encountered an error, {}'.format(r))

        return r

    @property
    def num_cycles(self):
        return self.contrl_mod.ncyc

    def get_summary(self, variable):
        """
        Return the FVS summary value for a single projection cycle.
        
        Args
        ----
        @param variable: The summary variable to return. One of the following:
                        year, age, tpa, total cuft, merch cuft, merch bdft, 
                        removed tpa, removed total cuft, removed merch cuft, 
                        removed merch bdft, baa after, ccf after, top ht after, 
                        period length, accretion, mortality, sample weight, 
                        forest type, size class, stocking class 
        """
        
        variables = {'year': 0
            , 'age': 1
            , 'tpa': 2
            , 'total cuft': 3
            , 'merch cuft': 4
            , 'merch bdft': 5
            , 'removed tpa': 6
            , 'removed total cuft': 7
            , 'removed merch cuft': 8
            , 'removed merch bdft': 9
            , 'baa after':10
            , 'ccf after':11
            , 'top ht after':12
            , 'period length':13
            , 'accretion':14
            , 'mortality':15
            , 'sample weight':16
            , 'forest type':17
            , 'size class':18
            , 'stocking class':19
            }

        try:
            i = variables[variable.lower()]
            
        except KeyError:
            msg = '{} is not an available summary variable({}).'.format(
                    variable, variables.keys())
            raise KeyError(msg)
            
        except:
            raise

        # Return the summary values for the cycles in the run
        return(self.fvslib.outcom_mod.iosum[i, :self.num_cycles + 1])

# def test():
    # # Config file for testing
    # pyfvs.config_path = os.path.join(os.path.split(__file__)[0], 'pyfvs.cfg')

    # import pylab
    # kwds = r'C:\workspace\Open-FVS\PyFVS\tests\pyfvs\fvspnc\pnt01.key'

    # # Demonstrate the stochastic variability in the FVS routines.
    # iters = 10
    # fvs = FVS('pnc', stochastic=True)

    # # Get species codes
    # spp_attrs = fvs.fvsspeciescode(16)
    # print(spp_attrs)

    # for i in range(iters):
        # fvs.run_fvs(kwds)

        # # Plot the BDFT volume
        # bdft = fvs.get_summary('merch bdft')
        # years = fvs.get_summary('year')
        # pylab.plot(years, bdft)

    # pylab.show()

def handle_command_line():
    """
    Return arguments collected from the command line.
    """
    import argparse

    parser = argparse.ArgumentParser(
            description='Open-FVS Python runner.')
    
    parser.add_argument('fvs_variant', type=str
            , metavar='FVS Variant'
            , help='FVS variant to run')
    
    parser.add_argument('keyword_file', type=str
            , metavar='Keyword File'
            , help='FVS keyword file to execute.')
            
    parser.add_argument('-s', '--stochastic', dest='stochastic'
            , action='store_true', default=False
            , help='Run FVS with stochastic components.')
            
    parser.add_argument('-d', '--debug', dest='debug'
            , action='store_true', default=False
            , help='Set logging level to debug.')
            
    args = parser.parse_args()
    
    return args

def main():
    """
    Execute a FVS projection from the command line.
    
    Basic Usage:
        python fvs.py -h
        python fvs.py <variant> <keyword file>
        python -m pyfvs.fvs <variant> <keyword file>
    """
    
    args = handle_command_line()
    
    if args.debug:
        log.setLevel(logging.DEBUG)
        
    try:
        fvs = FVS(args.fvs_variant, stochastic=args.stochastic)
        
    except ImportError:
        log.error(
            'Variant code \'{}\' is not '
            'a supported variant.'.format(args.fvs_variant))
        sys.exit(1)
    
    except:
        sys.exit(1)
        
    fvs.run_fvs(args.keyword_file)

    print(fvs.outcom_mod.iosum[:6, :fvs.num_cycles + 1].T)
#     print(fvs.get_summary('merch bdft'))

if __name__ == '__main__':
    if len(sys.argv)>1 and sys.argv[1]=='--test':
        test()
        
    else:
        main()
        