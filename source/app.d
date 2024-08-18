import std.stdio;
import bindbc.sdl;
import video;
import text;
import textures;
import types;
import game;

class App {
	bool     running = true;
	Vec2!int mousePos;

	this() {
		VideoComponents.Instance().Init("ymines");
		TextComponents.Instance();
		GameTextures.Instance();
		Game.Instance();

		GameTextures.Instance().LoadTextures();
	}

	static App Instance() {
		static App instance;

		if (!instance) {
			instance = new App();
		}

		return instance;
	}

	void Update() {
		auto      game = Game.Instance();
		SDL_Event e;

		while (SDL_PollEvent(&e)) {
			switch (e.type) {
				case SDL_QUIT: {
					running = false;
					break;
				}
				case SDL_MOUSEMOTION: {
					mousePos = Vec2!int(e.motion.x, e.motion.y);
					break;
				}
				case SDL_MOUSEBUTTONDOWN: {
					game.HandleClick(e);
					break;
				}
				default: continue;
			}
		}

		game.Render();

		SDL_RenderPresent(VideoComponents.Instance().renderer);
	}
}

void main() {
	auto app = App.Instance();

	while (app.running) {
		app.Update();
	}
}
