"""
pdbp configuration. Symlink to ~/.pdbrc.py to use it.
"""
import pdbp
from pygments.formatters import Terminal256Formatter


class Config(pdbp.DefaultConfig):

    sticky_by_default = True
    formatter = Terminal256Formatter(bg="dark", style="monokai")

    def setup(self, pdb):
        # make 'l' an alias to 'longlist', 'st' to 'sticky'
        Pdb = pdb.__class__
        Pdb.do_l = Pdb.do_longlist
        Pdb.do_st = Pdb.do_sticky
