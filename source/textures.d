import std.file;
import std.math;
import std.path;
import std.stdio;
import std.string;
import core.stdc.stdlib;
import bindbc.sdl;
import video;
import types;

static ubyte[] mineTexture  = cast(ubyte[]) import("assets/mine.png");
static ubyte[] flagTexture  = cast(ubyte[]) import("assets/flag.png");
static ubyte[] happyTexture = cast(ubyte[]) import("assets/happyFace.png");
static ubyte[] deadTexture  = cast(ubyte[]) import("assets/deadFace.png");
static ubyte[] coolTexture  = cast(ubyte[]) import("assets/coolFace.png");

enum Texture {
	Mine,
	Flag,
	HappyFace,
	DeadFace,
	CoolFace
}

class GameTextures {
	SDL_Texture*[Texture] textures;

	this() {
		auto support = loadSDLImage();
		// TODO: check if it failed
	
		if (!IMG_Init(IMG_INIT_PNG)) {
			stderr.writeln("Failed to initialise SDL_image");
			exit(1);
		}
	}

	~this() {
		IMG_Quit();
	}

	static GameTextures Instance() {
		static GameTextures inst;

		if (!inst) {
			inst = new GameTextures();
		}

		return inst;
	}

	void LoadTexture(Texture which, ref ubyte[] data) {
		auto         video   = VideoComponents.Instance();
		auto         rw      = SDL_RWFromMem(data.ptr, cast(int) data.length);
		SDL_Surface* surface = IMG_LoadTyped_RW(rw, 1, toStringz("PNG"));

		if (surface == null) {
			stderr.writefln(
				"Failed to load texture %s: %s", which, fromStringz(SDL_GetError())
			);
			exit(1);
		}
		
		SDL_Texture* texture = SDL_CreateTextureFromSurface(video.renderer, surface);

		if (surface == null) {
			stderr.writefln("Failed to create texture: %s", fromStringz(SDL_GetError()));
			exit(1);
		}
		
		textures[which]      = texture;

		SDL_FreeSurface(surface);
	}

	void LoadTextures() {
		LoadTexture(Texture.Mine,      mineTexture);
		LoadTexture(Texture.Flag,      flagTexture);
		LoadTexture(Texture.HappyFace, happyTexture);
		LoadTexture(Texture.DeadFace,  deadTexture);
		LoadTexture(Texture.CoolFace,  coolTexture);
	}

	void DrawAngledTexture(Texture which, Vec2!int pos, double angle, int scale) {
		auto     tex = textures[which];
		Vec2!int texSize;

		if (isNaN(angle)) {
			stderr.writeln("Error: angle is NaN");
			exit(1);
		}

		if (tex == null) {
			stderr.writeln("Tried to render NULL texture");
			exit(1);
		}

		SDL_QueryTexture(tex, null, null, &texSize.x, &texSize.y);
		SDL_Rect rect = SDL_Rect(
			pos.x, pos.y, texSize.x * scale, texSize.y * scale
		);

		SDL_RenderCopyEx(
			VideoComponents.Instance().renderer, tex, null, &rect, angle, null,
			SDL_FLIP_NONE
		);
	}

	void DrawTexture(Texture which, Vec2!int pos) {
		auto     tex   = textures[which];
		auto     video = VideoComponents.Instance();
		Vec2!int texSize;

		if (tex == null) {
			stderr.writeln("Tried to render NULL texture");
			exit(1);
		}

		SDL_QueryTexture(tex, null, null, &texSize.x, &texSize.y);
		SDL_Rect rect = SDL_Rect(
			pos.x, pos.y, texSize.x, texSize.y
		);

		if (SDL_RenderCopy(video.renderer, tex, null, &rect) != 0) {
			stderr.writefln("Failed to render: %s", fromStringz(SDL_GetError()));
			exit(1);
		}
	}
}
