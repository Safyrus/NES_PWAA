################################
# Constants
################################

EMPTY_NES_COLOR = 0x3F
BNK_SIZE = 1024
SPR_PER_BNK = 32
NB_NES_COLOR = 64
BLACK_NES_COLOR = 15
PAL_SIZE = 3
DEFAULT_PX_EQUA = 64 # how many pixel is needed before a tile is consider 'the same' with another tile
DEFAULT_MAX_BNK_COMBI = 10 # from 8 to 64. bigger = less sprite tiles but longer compute time
RES_FIRST_CHR_BYTES = 4096*2


################################
# SNIF Sprite Commands
################################

SPRCMD_END = 0x00
SPRCMD_FLIP = 0x04
SPRCMD_PAL = 0x08
SPRCMD_POS = 0x0C


################################
# img2neslimit constants
################################

# Constants that can be modified before running
MAX_SPRITE = 64  # Maximum number of sprites. Value beteen 0 and 64
MAX_TRANSPARENT_PX = 56  # Maximum number of transparent pixel before a tile is consider a border tile. Value beteen 0 and 64
BORDER_FACTOR = 1 # how important border sprites are. value from 1 to any positive integer
OVERFLOW_BEFOR_SPRITE = True # Remove sprites that overflow before removing them based on their number
FILL_BLACK = False # fill wrong backgroudn pixels with black (True) or with closest color (False)
MIN_PX_SPR = 8 # Minimum number of pixel for a sprite to be consider valid
MAX_LINE_OVERFLOW = 0 # Maximum number of line that can have sprite overflow. Value between 0 and MAX_IMG_HEIGHT
from PIL import Image
QUANTIZE_STRAT = Image.Quantize.MEDIANCUT

# Constants that should not be modified
MIN_IMG_WIDTH = 8
MIN_IMG_HEIGHT = 16
MAX_IMG_WIDTH = 256
MAX_IMG_HEIGHT = 240
MAX_SPRITE_OVERFLOW = 8
BLACK = [0, 0, 0, 255]
