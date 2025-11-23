--[[
    Support honest development retain this credit. 
    Don't claim you made it from scratch. Don't be that guy...

    MIT License

    Copyright (c) 2025 CaseIRL

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

--- @module engine.modules.audio
--- @description Handles audio playback.

--- @section FFI

local ffi = require("ffi")

ffi.cdef[[
    typedef struct rAudioBuffer rAudioBuffer;
    typedef struct rAudioProcessor rAudioProcessor;
    
    typedef struct AudioStream {
        rAudioBuffer *buffer;
        rAudioProcessor *processor;
        unsigned int sampleRate;
        unsigned int sampleSize;
        unsigned int channels;
    } AudioStream;
    
    typedef struct Wave {
        unsigned int frameCount;
        unsigned int sampleRate;
        unsigned int sampleSize;
        unsigned int channels;
        void *data;
    } Wave;
    
    typedef struct Sound {
        AudioStream stream;
        unsigned int frameCount;
    } Sound;

    Sound LoadSound(const char *fileName);
    void UnloadSound(Sound sound);
    void PlaySound(Sound sound);
    void StopSound(Sound sound);
    void PauseSound(Sound sound);
    void ResumeSound(Sound sound);
    void SetSoundVolume(Sound sound, float volume);
    void SetSoundPitch(Sound sound, float pitch);
    bool IsSoundValid(Sound sound);
    bool IsSoundPlaying(Sound sound);
    
    Wave LoadWave(const char *fileName);
    bool IsWaveValid(Wave wave);
    Sound LoadSoundFromWave(Wave wave);
    void UnloadWave(Wave wave);
]]

local _rl = ffi.load("raylib")

--- @section Module

local audio = {
    sounds = {},
    music = {},
    current_music = nil,
    music_loop = {},
    music_volume_fade = {}
}

--- Load a sound effect from file.
--- @param key string Unique identifier for this sound
--- @param path string Path to sound file (WAV, OGG, etc)
function audio.load_sound(key, path)
    if audio.sounds[key] then
        return
    end
    local sound = _rl.LoadSound(path)
    if _rl.IsSoundValid(sound) then
        audio.sounds[key] = sound
    end
end

--- Load a music track from file.
--- @param key string Unique identifier for this music
--- @param path string Path to music file (WAV, OGG, etc)
function audio.load_music(key, path)
    if audio.music[key] then
        return
    end
    
    local wave = _rl.LoadWave(path)
    if not _rl.IsWaveValid(wave) then
        print("Failed to load wave: " .. path)
        return false
    end
    
    local sound = _rl.LoadSoundFromWave(wave)
    _rl.UnloadWave(wave)
    
    if not _rl.IsSoundValid(sound) then
        print("Failed to convert wave to sound: " .. path)
        return false
    end
    
    audio.music[key] = sound
    audio.music_loop[key] = false
    return true
end

--- Play a sound effect.
--- @param key string Sound identifier (must be loaded first)
function audio.play_sound(key)
    if audio.sounds[key] then
        _rl.PlaySound(audio.sounds[key])
    end
end

--- Play music (stops current music if playing).
--- @param key string Music identifier (must be loaded first)
--- @param loop? boolean Whether to loop (default: false)
function audio.play_music(key, loop)
    if not audio.music[key] then
        return
    end
    
    if audio.current_music and audio.current_music ~= key then
        _rl.StopSound(audio.music[audio.current_music])
    end
    
    audio.current_music = key
    audio.music_loop[key] = loop or false
    _rl.PlaySound(audio.music[key])
end

--- Stop current music.
function audio.stop_music()
    if audio.current_music and audio.music[audio.current_music] then
        _rl.StopSound(audio.music[audio.current_music])
        audio.current_music = nil
    end
end

--- Pause current music.
function audio.pause_music()
    if audio.current_music and audio.music[audio.current_music] then
        _rl.PauseSound(audio.music[audio.current_music])
    end
end

--- Resume current music.
function audio.resume_music()
    if audio.current_music and audio.music[audio.current_music] then
        _rl.ResumeSound(audio.music[audio.current_music])
    end
end

--- Set volume for a sound effect (0.0 to 1.0).
--- @param key string Sound identifier
--- @param volume number Volume level (0.0 = silent, 1.0 = full)
function audio.set_sound_volume(key, volume)
    if audio.sounds[key] then
        _rl.SetSoundVolume(audio.sounds[key], math.max(0, math.min(1, volume)))
    end
end

--- Set pitch/playback speed for a sound effect (1.0 = normal).
--- @param key string Sound identifier
--- @param pitch number Pitch level (0.5 = half speed, 2.0 = double speed)
function audio.set_sound_pitch(key, pitch)
    if audio.sounds[key] then
        _rl.SetSoundPitch(audio.sounds[key], pitch)
    end
end

--- Set volume for music (0.0 to 1.0).
--- @param key string Music identifier
--- @param volume number Volume level (0.0 = silent, 1.0 = full)
function audio.set_music_volume(key, volume)
    if audio.music[key] then
        _rl.SetSoundVolume(audio.music[key], math.max(0, math.min(1, volume)))
    end
end

--- Set pitch/playback speed for music (1.0 = normal).
--- @param key string Music identifier
--- @param pitch number Pitch level (0.5 = half speed, 2.0 = double speed)
function audio.set_music_pitch(key, pitch)
    if audio.music[key] then
        _rl.SetSoundPitch(audio.music[key], pitch)
    end
end

--- Check if music is currently playing.
--- @return boolean True if music is playing
function audio.is_music_playing()
    if audio.current_music and audio.music[audio.current_music] then
        return _rl.IsSoundPlaying(audio.music[audio.current_music])
    end
    return false
end

--- Unload a sound effect.
--- @param key string Sound identifier
function audio.unload_sound(key)
    if audio.sounds[key] then
        _rl.UnloadSound(audio.sounds[key])
        audio.sounds[key] = nil
    end
end

--- Unload music.
--- @param key string Music identifier
function audio.unload_music(key)
    if audio.music[key] then
        _rl.UnloadSound(audio.music[key])
        audio.music[key] = nil
        audio.music_loop[key] = nil
    end
end

--- Clean up all audio resources.
function audio.cleanup()
    for key in pairs(audio.sounds) do
        audio.unload_sound(key)
    end
    for key in pairs(audio.music) do
        audio.unload_music(key)
    end
end

return audio