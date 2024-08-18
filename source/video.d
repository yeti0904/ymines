import std.file;
import std.path;
import std.stdio;
import std.string;
import core.stdc.stdlib;
import bindbc.sdl;
import types;

class VideoComponents {
	SDL_Window*   window;
	SDL_Renderer* renderer;
	Vec2!int      windowSize;

	this() {
		
	}

	~this() {
		SDL_DestroyWindow(window);
		SDL_DestroyRenderer(renderer);
		SDL_Quit();
	}

	static VideoComponents Instance() {
		static VideoComponents ret;

		if (!ret) {
			ret = new VideoComponents();
		}

		return ret;
	}

	void Init(string windowName) {
		// load SDL
		SDLSupport support = loadSDL();
		if (support != sdlSupport) {
			stderr.writeln("Failed to load SDL");
			exit(1);
		}
		version (Windows) {
			loadSDL(toStringz(dirName(thisExePath()) ~ "/sdl2.dll"));
		}

		// init
		if (SDL_Init(SDL_INIT_VIDEO) < 0) {
			stderr.writefln("Failed to init SDL: %s", fromStringz(SDL_GetError()));
			exit(1);
		}

		// window
		windowSize = Vec2!int(160, 192);
		window = SDL_CreateWindow(
			cast(char*) toStringz(windowName),
			SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
			windowSize.x * 2, windowSize.y * 2, 0
		);
		if (window is null) {
			stderr.writefln("Failed to create window: %s", fromStringz(SDL_GetError()));
			exit(1);
		}

		renderer = SDL_CreateRenderer(
			window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
		);
		if (renderer is null) {
			stderr.writefln("Failed to create renderer: %s", fromStringz(SDL_GetError()));
			exit(1);
		}
		SDL_RenderSetLogicalSize(renderer, 160, 192);
	}

	void SetHexColour(uint colour) {
		SDL_SetRenderDrawColor(
			renderer,
			cast(ubyte) ((colour & 0xFF0000) >> 16), // R
			cast(ubyte) ((colour & 0x00FF00) >> 8),  // G
			cast(ubyte) (colour & 0x0000FF),         // B
			255
		);
	}

	SDL_Color ColourFromHex(uint colour) {
		return SDL_Color(
			cast(ubyte) ((colour & 0xFF0000) >> 16), // R,
			cast(ubyte) ((colour & 0x00FF00) >> 8), // G,
			cast(ubyte) (colour & 0x0000FF),        // B,
			255
		);
	}
}
