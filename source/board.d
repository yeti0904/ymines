import std.random;
import std.stdio;
import types;

struct Cell {
	bool  isMine;
	ubyte surroundingMines;
	bool  revealed;
	bool  flagged;
	bool  visited;
}

class Board {
	Cell[][] cells;
	size_t   amountOfMines;

	this(size_t size, size_t nMines) {
		cells         = new Cell[][](size, size);
		amountOfMines = nMines;
	}

	~this() {
		
	}

	void Reveal(Vec2!size_t pos, bool firstRun = true) {
		if (firstRun) {
			foreach (ref line ; cells) {
				foreach (ref cell ; line) {
					cell.visited = false;
				}
			}
		}
	
		if ((pos.x >= cells.length) || (pos.y >= cells.length)) {
			return;
		}

		if (cells[pos.y][pos.x].visited) {
			return;
		}

		if (cells[pos.y][pos.x].surroundingMines > 0) {
			cells[pos.y][pos.x].revealed = true;
			return;
		}

		cells[pos.y][pos.x].visited  = true;
		cells[pos.y][pos.x].revealed = true;

		Reveal(Vec2!size_t(pos.x + 1, pos.y),     false);
		Reveal(Vec2!size_t(pos.x - 1, pos.y),     false);
		Reveal(Vec2!size_t(pos.x,     pos.y + 1), false);
		Reveal(Vec2!size_t(pos.x,     pos.y - 1), false);

		Reveal(Vec2!size_t(pos.x - 1, pos.y + 1), false);
		Reveal(Vec2!size_t(pos.x + 1, pos.y - 1), false);
		Reveal(Vec2!size_t(pos.x - 1, pos.y - 1), false);
		Reveal(Vec2!size_t(pos.x + 1, pos.y + 1), false);
	}
	
	void GenerateMines() {
		for (size_t i = 0; i < amountOfMines; ++ i) {
			while (true) {
				Vec2!size_t pos = Vec2!size_t(
					uniform(0, cells.length), uniform(0, cells.length)
				);

				if (!cells[pos.y][pos.x].isMine) {
					cells[pos.y][pos.x].isMine = true;
					break;
				}
			}
		}

		// create surrounding mines
		for (size_t i = 0; i < cells.length; ++i) {
			for (size_t j = 0; j < cells.length; ++j) {
				Vec2!size_t[] checks;

				if (i != 0) {
					checks ~= Vec2!size_t(j, i - 1);
				}
				if (j != 0) {
					checks ~= Vec2!size_t(j - 1, i);
				}
				if (i < cells.length - 1) {
					checks ~= Vec2!size_t(j, i + 1);
				}
				if (j < cells.length - 1) {
					checks ~= Vec2!size_t(j + 1, i);
				}

				if ((i != 0) && (i != 0)) {
					checks ~= Vec2!size_t(j - 1, i - 1);
				}
				if ((i != 0) && (j < cells.length - 1)) {
					checks ~= Vec2!size_t(j + 1, i - 1);
				}
				if ((i < cells.length - 1) && (j != 0)) {
					checks ~= Vec2!size_t(j - 1, i + 1);
				}
				if ((i < cells.length - 1) && (j < cells.length - 1)) {
					checks ~= Vec2!size_t(j + 1, i + 1);
				}

				foreach (ref check ; checks) {
					Cell cell;

					try {
						cell = cells[check.y][check.x];
					}
					catch (Throwable) {
						
					}
					
					if (cell.isMine) {
						++ cells[i][j].surroundingMines;
					}
				}
			}
		}
	}

	int CountFlags() {
		int ret;
		
		foreach (ref line ; cells) {
			foreach (ref cell ; line) {
				if (cell.flagged) {
					++ ret;
				}
			}
		}

		return ret;
	}

	bool HasWon() {
		foreach (ref line ; cells) {
			foreach (ref cell ; line) {
				if (!cell.revealed && !cell.isMine) {
					return false;
				}
			}
		}

		return true;
	}
}
