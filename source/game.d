import std.conv;
import std.stdio;
import bindbc.sdl;
import app;
import text;
import board;
import video;
import types;
import textures;

enum GameState {
	Playing,
	Win,
	Lose
}

class Game {
	Board     board;
	bool      firstTurn;
	GameState state;
	SDL_Rect  faceRect;

	this() {
		auto video = VideoComponents.Instance();
	
		board     = new Board(10, 10);
		firstTurn = true;
		state     = GameState.Playing;
		board.GenerateMines();

		faceRect = SDL_Rect((video.windowSize.x / 2) - 8, 8, 16, 16);
	}

	~this() {
		
	}

	static Game Instance() {
		static Game instance;

		if (!instance) {
			instance = new Game();
		}

		return instance;
	}

	void Reset() {
		state = GameState.Playing;
		firstTurn = true;
		board     = new Board(10, 10);
		board.GenerateMines();
	}

	void HandleClick(SDL_Event e) {
		auto app = App.Instance();

		auto mousePos  = app.mousePos;
		mousePos.y    -= 32;

		if (mousePos.y < 0) {
			mousePos = app.mousePos;

			if (
				(mousePos.x >= faceRect.x) &&
				(mousePos.y >= faceRect.y) &&
				(mousePos.x < faceRect.x + faceRect.w) &&
				(mousePos.y < faceRect.y + faceRect.h)
			) {
				Reset();
			}

			return;
		}
		
		mousePos.x /= 16;
		mousePos.y /= 16;
	
		switch (e.button.button) {
			case SDL_BUTTON_LEFT: {
				if (state != GameState.Playing) {
					break;
				}
				bool hasLost;
			
				board.Reveal(Vec2!size_t(mousePos.x, mousePos.y));

				if (firstTurn) {
					while (board.cells[mousePos.y][mousePos.x].surroundingMines > 0) {
						board = new Board(10, 10);
						board.GenerateMines();
					}
				}

				if (board.cells[mousePos.y][mousePos.x].isMine) {
					if (firstTurn) {
						while (board.cells[mousePos.y][mousePos.x].isMine) {
							board = new Board(10, 10);
							board.GenerateMines();
						}

						board.cells[mousePos.y][mousePos.x].revealed = true;
					}
					else {
						state = GameState.Lose;
						foreach (ref line ; board.cells) {
							foreach (ref cell ; line) {
								cell.revealed = true;
							}
						}
					}
				}
				
				if (board.HasWon() && (state != GameState.Lose)) {
					state = GameState.Win;
				}

				firstTurn = false;
				break;
			}
			case SDL_BUTTON_RIGHT: {
				if (state != GameState.Playing) {
					break;
				}
				
				board.cells[mousePos.y][mousePos.x].flagged =
					!board.cells[mousePos.y][mousePos.x].flagged;
				break;
			}
			default: break;
		}
	}

	void Render() {
		auto text     = TextComponents.Instance();
		auto video    = VideoComponents.Instance();
		auto textures = GameTextures.Instance();

		video.SetHexColour(0x2f4d2f);
		SDL_RenderClear(video.renderer);

		for (size_t i = 0; i < board.cells.length; ++i) {
			for (size_t j = 0; j < board.cells.length; ++j) {
				Vec2!size_t pos  = Vec2!size_t(j * 16, (i * 16) + 32);
				auto        cell = board.cells[i][j];
				SDL_Rect    rect = SDL_Rect(cast(int) pos.x, cast(int) pos.y, 16, 16);

				if (cell.revealed) {
					if (cell.isMine) {
						if (cell.flagged) {
							video.SetHexColour(0x44702d);
						}
						else {
							video.SetHexColour(0xb55945);
						}
					}
					else {
						video.SetHexColour(0x44702d);
					}
				}
				else {
					video.SetHexColour(0xd5d6db);
				}

				SDL_RenderFillRect(video.renderer, &rect);

				if (cell.revealed && cell.isMine) {
					SDL_RenderCopy(
						video.renderer, textures.textures[Texture.Mine], null, &rect
					);
				}
				if (!cell.revealed && cell.flagged) {
					SDL_RenderCopy(
						video.renderer, textures.textures[Texture.Flag], null, &rect
					);
				}

				if (!cell.isMine && (cell.surroundingMines > 0) && cell.revealed) {
					string   num     = std.conv.text(cell.surroundingMines);
					Vec2!int textPos = Vec2!int(cast(int) pos.x, cast(int) pos.y);

					auto add = text.GetTextSize(num);

					textPos.x += 8 - (add.x / 2);
					textPos.y += 8 - (add.y / 2);
					
					text.DrawText(
						video.renderer, num, textPos, video.ColourFromHex(0xf1f6f0)
					);
				}

				video.SetHexColour(0x303843);
				SDL_RenderDrawRect(video.renderer, &rect);
			}
		}

		// render the funny face
		SDL_Texture* texture;

		switch (state) {
			case GameState.Playing: {
				texture = textures.textures[Texture.HappyFace];
				break;
			}
			case GameState.Win: {
				texture = textures.textures[Texture.CoolFace];
				break;
			}
			case GameState.Lose: {
				texture = textures.textures[Texture.DeadFace];
				break;
			}
			default: assert(0);
		}

		SDL_RenderCopy(video.renderer, texture, null, &faceRect);

		// render mines left
		{
			int minesLeft     = cast(int) board.amountOfMines - board.CountFlags;
			string   theText  = std.conv.text(minesLeft);
			Vec2!int textSize = text.GetTextSize(theText);
			Vec2!int pos      = Vec2!int(
				(video.windowSize.x / 4) - (textSize.x / 2),
				16 - (textSize.y / 2)
			);
			text.DrawText(video.renderer, theText, pos, video.ColourFromHex(0xf1f6f0));
		}
	}
}
