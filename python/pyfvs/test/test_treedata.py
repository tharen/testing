'''
Created on Jan 12, 2016

@author: THAREN
'''
import os
import unittest
import pytest
import pandas as pd
import numpy as np

import pyfvs
from pyfvs import fvs

variants = [('pnc',), ('wcc',), ('soc',), ('cac',), ('oc',)]

root = os.path.split(__file__)[0]
bare_ground_params = [
        ['pnc', 'rmrs/pn_bareground.key', 'rmrs/pn_bareground.sum.save'],
        ['wcc', 'rmrs/wc_bareground.key', 'rmrs/wc_bareground.sum.save'],
        ['soc', 'rmrs/so_bareground.key', 'rmrs/so_bareground.sum.save'],
        ['cac', 'rmrs/ca_bareground.key', 'rmrs/ca_bareground.sum.save'],
        ['oc', 'rmrs/oc_bareground.key', 'rmrs/oc_bareground.sum.save'],
        ]

@pytest.mark.parametrize(('variant', 'kwd_path', 'sum_path'), bare_ground_params)
def test_tree_data(variant, kwd_path, sum_path):
    try:
        f = fvs.FVS(variant)

    except ImportError:
        pytest.skip('No variant library: {}'.format(variant))
        return None

    except:
        raise

    print('**', kwd_path)
    f.init_projection(os.path.join(root, kwd_path))
    f.tree_data.live_tpa[:, :] = 0.0

    for c in range(f.contrl_mod.ncyc):
        r = f.grow_projection()

    r = f.end_projection()
    assert r == 0

    widths = [4, 4, 6, 4, 5, 4, 4, 5, 6, 6, 6, 6, 6, 6, 6, 4, 5, 4, 4, 5, 8, 5, 6, 8, 4, 2, 1]
    fldnames = (
            'year,age,tpa,baa,sdi,ccf,top_ht,qmd,total_cuft'
            ',merch_cuft,merch_bdft,rem_tpa,rem_total_cuft'
            ',rem_merch_cuft,rem_merch_bdft,res_baa,res_sdi'
            ',res_ccf,res_top_ht,resid_qmd,grow_years'
            ',annual_acc,annual_mort,mai_merch_cuft,for_type'
            ',size_class,stocking_class'
            ).split(',')

    # Read the sum file generated by the "official" FVS executable
    sum_check = pd.read_fwf(os.path.join(root, sum_path), skiprows=0, widths=widths)
    sum_check.columns = fldnames

    ncyc = f.contrl_mod.ncyc

    # TPA +/- 1
    tpa = np.round(np.sum(f.tree_data.live_tpa[:, :ncyc + 1], axis=0), 0).astype(int)
    check_tpa = sum_check.loc[:, 'tpa'].values
    assert np.all(np.isclose(check_tpa, tpa, atol=1))

    # BAA +/- 1
    tpa = f.tree_data.live_tpa[:, :ncyc + 1]
    dbh = f.tree_data.live_dbh[:, :ncyc + 1]

    baa = tpa * dbh * dbh * 0.005454154
    baa = np.round(np.sum(baa, axis=0), 0).astype(int)
    check_baa = sum_check.loc[:, 'baa'].values
    assert np.all(np.isclose(check_baa, baa, atol=1))

    # Total CuFt +/- 1
    tpa = f.tree_data.live_tpa[:, :ncyc + 1]
    cuft = f.tree_data.cuft_total[:, :ncyc + 1]
    tot_cuft = np.round(np.sum(tpa * cuft, axis=0), 0).astype(int)
    check_cuft = sum_check.loc[:, 'total_cuft'].values
    assert np.all(np.isclose(check_cuft, tot_cuft, atol=1))

    # Total BdFt +/- 1
    tpa = f.tree_data.live_tpa[:, :ncyc + 1]
    bdft = f.tree_data.bdft_net[:, :ncyc + 1]
    tot_bdft = np.round(np.sum(tpa * bdft, axis=0), 0).astype(int)
    check_bdft = sum_check.loc[:, 'merch_bdft'].values
    assert np.all(np.isclose(check_bdft, tot_bdft, atol=1))

#     for fld in fldnames[:18]:
#         assert np.array_equal(sum_check.loc[:,fld],sum_test.loc[:,fld])

if __name__ == '__main__':
    test_tree_data(*bare_ground_params[0])

