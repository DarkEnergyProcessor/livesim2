-- Tap sound definition
-- Part of Live Simulator: 2
-- See copyright notice in main.lua

return {
	-- Usual SIF tap SFX
	{
		name = "Default",
		volumeMultipler = 0.75,
		perfect = "sound/tap/sif/SE_306.ogg",
		great = "sound/tap/sif/SE_307.ogg",
		good = "sound/tap/sif/SE_308.ogg",
		bad = "sound/tap/sif/SE_309.ogg",
		starExplode = "sound/tap/sif/SE_326.ogg"
	},
	-- don't ask
	{
		name = "GBP:Default",
		volumeMultipler = 1,
		perfect = "sound/tap/gbp/00005.wav",
		great = "sound/tap/gbp/00004.wav",
		good = "sound/tap/gbp/00002.wav",
		bad = "sound/tap/gbp/00003.wav",
		starExplode = "sound/tap/sif/SE_326.ogg"
	},
	-- especially this one
	{
		name = "GBP:Michelle",
		volumeMultipler = 1,
		perfect = "sound/tap/gbp/a/00005.wav",
		great = "sound/tap/gbp/a/00004.wav",
		good = "sound/tap/gbp/a/00002.wav",
		bad = "sound/tap/gbp/a/00003.wav",
		starExplode = "sound/tap/sif/SE_326.ogg"
	},
	-- and even this one
	{
		name = "GBP:Miku",
		volumeMultipler = 1,
		perfect = "sound/tap/gbp/miku/perfect.wav",
		great = "sound/tap/gbp/miku/great.wav",
		good = "sound/tap/gbp/miku/good.wav",
		bad = "sound/tap/gbp/miku/game_button.wav",
		starExplode = "sound/tap/sif/SE_326.ogg"
	},
	-- New SIF tap sound
	{
		name = "SIF:Clap",
		volumeMultipler = 0.8,
		perfect = "sound/tap/sif/live_se_02_4.mp3",
		great = "sound/tap/sif/live_se_02_3.mp3",
		good = "sound/tap/sif/live_se_02_2.mp3",
		bad = "sound/tap/sif/live_se_02_1.mp3",
		starExplode = "sound/tap/sif/SE_326.ogg"
	},
	{
		name = "SIF:Bubble",
		volumeMultipler = 0.8,
		perfect = "sound/tap/sif/live_se_03_4.mp3",
		great = "sound/tap/sif/live_se_03_3.mp3",
		good = "sound/tap/sif/live_se_03_2.mp3",
		bad = "sound/tap/sif/live_se_03_1.mp3",
		starExplode = "sound/tap/sif/SE_326.ogg"
	},
	{
		name = "SIF:SF",
		volumeMultipler = 0.8,
		perfect = "sound/tap/sif/live_se_04_4.mp3",
		great = "sound/tap/sif/live_se_04_3.mp3",
		good = "sound/tap/sif/live_se_04_2.mp3",
		bad = "sound/tap/sif/live_se_04_1.mp3",
		starExplode = "sound/tap/sif/SE_326.ogg"
	},
	-- Welcome to osu!
	{
		name = "osu!lazer",
		volumeMultipler = 0.9,
		perfect = "sound/tap/osu/perfect.wav",
		great = "sound/tap/osu/great.wav",
		good = "sound/tap/osu/good.wav",
		bad = "sound/tap/osu/bad.wav",
		starExplode = "sound/tap/osu/star.wav"
	},
}
