#ifndef META_PARAM_H
#define META_PARAM_H

#include "tile.h"

#define SPR_MIN_PX_THRESHOLD 16 // minimum number of pixels that a sprite need to be valid. Range is 0-128
#define SPR_SIMILAR_THRESHOLD 8 // minimum difference for a sprite to be unique. Range is 0-128
#define BKG_SIMILAR_THRESHOLD 3 // minimum difference for a background tile to be unique. Range is 0-64
#define BKG_MAX_TILES MAX_TILES // maximum number of backgroun tiles. Should be <= to MAX_TILES

#endif
