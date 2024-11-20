import numpy as np


def tile2chr(tile):
    assert tile.dtype == np.uint8
    data = bytearray()
    # first plane
    for row in tile:
        bits = np.bitwise_and(row, 0b01)
        data.append(np.packbits(bits)[0])
    # second plane
    for row in tile:
        bits = np.bitwise_and(row, 0b10)
        data.append(np.packbits(bits)[0])
    return data


def tiles2chr(tiles):
    data = bytearray()
    for t in tiles:
        data.extend(tile2chr(t))
    return data


def chr2tile(data):
    tile = np.zeros((8, 8), dtype=np.uint8)
    # first plane
    for i in range(8):
        row = np.unpackbits(np.array(data[i], dtype= np.uint8))
        tile[i] = row
    # second plane
    for i in range(8):
        row = np.unpackbits(np.array(data[i+8], dtype= np.uint8))
        tile[i] |= row << 1
    return tile


def chr2tiles(data):
    tiles = []
    for i in range(0, len(data), 16):
        tiles.append(chr2tile(data[i : i + 16]))
    return np.array(tiles, dtype=np.uint8)
