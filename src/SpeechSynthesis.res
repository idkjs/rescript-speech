/* https://github.com/gaelduplessix/speechful */

module Voice = {
  /* type t; */

  @deriving(abstract)
  type t = {
    lang: string,
    name: string,
  }

  @get external langGet: t => string = "lang"
  @get external nameGet: t => string = "name"
}

module Utterance = {
  type t
  @new external create: string => t = "SpeechSynthesisUtterance"
  /* properties */
  @get external get_lang: t => string = "lang"
  @set external set_lang: (t, string) => unit = "lang"
  @get external get_pitch: t => float = "pitch"
  @set external set_pitch: (t, float) => unit = "pitch"
  @get external get_rate: t => float = "rate"
  @set external set_rate: (t, float) => unit = "rate"
  @get external get_text: t => string = "text"
  @set external set_text: (t, string) => unit = "text"
  @get external get_voice: t => Voice.t = "voice"
  @set external set_voice: (t, Voice.t) => unit = "voice"
  @get external get_volume: t => float = "volume"
  @set external set_volume: (t, float) => unit = "volume"
  /* event handlers */
  @set external on_end: (t, unit => unit) => unit = "onend"
}

/* Methods on global `speechSynthesis` object */
@scope("window.speechSynthesis") @val
external getVoices: unit => array<Voice.t> = ""

@scope("window.speechSynthesis") @val
external speak: Utterance.t => unit = ""

/* Setters */
type t_globalSpeechSynthesis

@val @scope("window")
external globalSpeechSynthesis: t_globalSpeechSynthesis = "speechSynthesis"

@set
external setOnVoicesChanged: (t_globalSpeechSynthesis, unit => unit) => unit = "onvoiceschanged"

let onVoicesChanged = (cb: unit => unit) => setOnVoicesChanged(globalSpeechSynthesis, cb)
