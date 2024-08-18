import std.file;
import std.path;
import std.stdio;
import std.string;
import core.stdc.stdlib;
import bindbc.sdl;
import types;

static ubyte[] fontData = cast(ubyte[]) import("assets/font.ttf");

class TextComponents {
	TTF_Font* font;

	this() {
		font = null;

		auto support = loadSDLTTF();
		// TODO: check if it failed

		if (TTF_Init() == -1) {
			stderr.writefln(
				"Failed to initialise SDL_TTF: %s", fromStringz(TTF_GetError())
			);
			exit(1);
		}

		auto rw = SDL_RWFromMem(fontData.ptr, cast(int) fontData.length);
		font = TTF_OpenFontRW(rw, 1, 16);
		if (font is null) {
			stderr.writefln(
				"Failed to initialise SDL_TTF: %s", fromStringz(TTF_GetError())
			);
			exit(1);
		}
	}

	~this() {
		if (font !is null) {
			TTF_CloseFont(font);
		}
		if (TTF_WasInit()) {
			TTF_Quit();
		}
	}

	static TextComponents Instance() {
		static TextComponents instance;

		if (instance is null) {
			instance = new TextComponents();
		}

		return instance;
	}

	void DrawText(
		SDL_Renderer* renderer, string text, Vec2!int pos, SDL_Color colour
	) {
		SDL_Surface* textSurface;
		SDL_Texture* textTexture;

		textSurface = TTF_RenderText_Solid(font, toStringz(text), colour);
		if (textSurface is null) {
			stderr.writefln("Failed to render text: %s", fromStringz(TTF_GetError()));
			exit(1);
		}

		SDL_Rect textRect = SDL_Rect(pos.x, pos.y, textSurface.w, textSurface.h);
		
		textTexture = SDL_CreateTextureFromSurface(renderer, textSurface);
		if (textTexture is null) {
			stderr.writefln("Failed to create texture: %s", fromStringz(TTF_GetError()));
			exit(1);
		}

		SDL_RenderCopy(renderer, textTexture, null, &textRect);

		SDL_FreeSurface(textSurface);
		SDL_DestroyTexture(textTexture);
	}

	Vec2!int GetTextSize(string text) {
		if (text.empty()) {
			return Vec2!int(0, 0);
		}

		SDL_Surface* textSurface;
		SDL_Colour   colour = SDL_Color(0, 0, 0, 255);
		SDL_Rect     textRect;

		textSurface = TTF_RenderText_Solid(font, toStringz(text), colour);
		if (textSurface is null) {
			stderr.writefln(
				"TTF_RenderText_Solid returned NULL: %s", fromStringz(TTF_GetError())
			);
			exit(1);
		}
		Vec2!int ret = Vec2!int(textSurface.w, textSurface.h);

		SDL_FreeSurface(textSurface);

		return ret;
	}
}
