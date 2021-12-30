// @react.component
// let make = () => <Main />

%raw(`require('./App.css')`)

open List

type state = {
  allCards: Dictionaries.pairList,
  remainingCards: Dictionaries.pairList,
  appcodeIsSpeaking: bool,
  showEnglish: bool,
  showSettings: bool,
  showVoiceMenu: bool,
  voices: array<SpeechSynthesis.Voice.t>,
  dangerColor: string,
  englishTextColor: string,
  settingsColor: string,
  baseTextColor: string,
}

type action =
  | GotoNextCard
  | GotoPreviousCard(int)
  | SwitchEnglishShowing(string, int)
  | SpeakEnglish
  | SpeechEnd
  | ShowSettingsMenu
  | ShowVoiceMenu
  | HideSettingsMenu
  | HideVoiceMenu
  | StoreVoicesToSate(array<SpeechSynthesis.Voice.t>)
  | Restart

let initialState = {
  /* 11 fields */
  allCards: list{},
  remainingCards: list{},
  appcodeIsSpeaking: false,
  showEnglish: false,
  showSettings: false,
  showVoiceMenu: false,
  voices: [],
  dangerColor: "#000",
  englishTextColor: "#000",
  settingsColor: "#000",
  baseTextColor: "#000",
}
@react.component
let make = () => {
  let (state, dispatch) = React.useReducer((state, action) =>
    switch action {
    | GotoNextCard => {
        ...state,
        remainingCards: MyLib.dropItems(1, state.remainingCards),
        showEnglish: false,
      }

    | GotoPreviousCard(index) =>
      let newCurrentDictionary = if index < 0 {
        state.allCards
      } else {
        MyLib.dropItems(index, state.allCards)
      }
      {...state, remainingCards: newCurrentDictionary}

    | ShowSettingsMenu => {...state, showSettings: true}
    | HideSettingsMenu => {...state, showSettings: false}
    | ShowVoiceMenu => {...state, showVoiceMenu: true}
    | HideVoiceMenu => {...state, showVoiceMenu: false}
    | SpeechEnd => {...state, appcodeIsSpeaking: false}

    | SpeakEnglish =>
      switch state.appcodeIsSpeaking {
      | true => state
      | false => {...state, appcodeIsSpeaking: true}
      }

    | SwitchEnglishShowing(str, shown) =>
      let newShowEnglish = state.showEnglish != true
      if newShowEnglish {
        open Dom.Storage
        localStorage |> setItem(str, string_of_int(shown + 1))
      }
      {...state, showEnglish: newShowEnglish, appcodeIsSpeaking: false}

    | StoreVoicesToSate(voices) => {...state, voices: voices}

    | Restart => {
        Js.log("Restart")
        Random.self_init()

        let item = {
          open Dom.Storage
          localStorage |> getItem(Constants.dict)
        }

        let (dict, dictOld) = {
          open Dictionaries
          switch item {
          | Some(_) => (dictionary2, List.append(dictionary20, oldDictionary2))
          | None => (dictionary1, List.append(dictionary10, oldDictionary1))
          }
        }

        let allCards =
          append(
            MyLib.takeItems(
              Constants.numberOfPairsFromOldDictionary,
              Reshuffle.reshuffle4(dictOld),
            ),
            Reshuffle.reshuffle4(dict),
          ) |> filter(({rus, eng}: Dictionaries.wordPair) => eng !== "" || rus !== "")

        let (baseTextColor, settingsColor, englishTextColor, dangerColor) = MyLib.getColorsFromCSS()

        {
          ...state,
          allCards: allCards,
          remainingCards: allCards,
          appcodeIsSpeaking: false,
          showEnglish: false,
          showSettings: false,
          showVoiceMenu: false,
          baseTextColor: /* only voices field is absent */
          baseTextColor,
          settingsColor: settingsColor,
          englishTextColor: englishTextColor,
          dangerColor: dangerColor,
        }
      }
    }
  , initialState)
  // (); /* in case of utterThis.onend failed */
  // }

  let speakEnglish = text => {
    let ut = SpeechSynthesis.Utterance.create("")
    let ti = Js.Global.setTimeout(
      _ => dispatch(SpeechEnd),
      7000 /* in case of utterThis.onend failed */,
    )
    // let ti2 = Js.Global.setTimeout(() => {
    //   dispatch(SpeechEnd)
    // }, 7000)->ignore
    let voiceIndex = MyLib.getVoiceIndex()
    if voiceIndex >= 0 && voiceIndex < Array.length(state.voices) {
      SpeechSynthesis.Utterance.set_voice(ut, state.voices[voiceIndex])
    }
    SpeechSynthesis.Utterance.on_end(ut, _ => {
      dispatch(SpeechEnd)
      Js.Global.clearTimeout(ti)
    })
    let regex = %re("/\/\//")
    let splitedList0 = Js.String.splitByRe(regex, text)->Belt.Array.keepMap(text => text)

    let splitedList1 = Js.Array.mapi((a, index) =>
      {
        open Int32
        rem(of_int(index), of_int(2)) === of_int(0)
      }
        ? a
        : ""
    , splitedList0)

    let textWithoutComments = Js.Array.joinWith("", splitedList1)

    SpeechSynthesis.Utterance.set_text(ut, textWithoutComments)
    let _ = Js.Global.setTimeout(_ => SpeechSynthesis.speak(ut), 150)
  }

  React.useEffect0(() => {
    let _ = SpeechSynthesis.getVoices()
    let _ = Js.Global.setTimeout(_ => {
      let voices = SpeechSynthesis.getVoices()
      dispatch(StoreVoicesToSate(voices))
    }, 100)
    dispatch(Restart)
    None
  })

  Js.log("App render")
  switch state.remainingCards {
  | list{} =>
    <div
      onClick={_ => dispatch(Restart)}
      onDoubleClick={_ => dispatch(Restart)}
      className="popup__opacity_1 popup_voices_zindex">
      <div className="popup__full_screen_div_opacity" />
      <div className="popup__full_screen_div">
        <div className="popup__window popup__scroll appcode__eng_text_color">
          {React.string("That's all!. Click to restart.")}
        </div>
      </div>
    </div>

  | list{currentCard, ...tail} =>
    let countAll = length(state.allCards)
    let countRemain = length(tail)
    let item = {
      open Dom.Storage
      localStorage |> getItem(currentCard.rus)
    }
    let shown = switch item {
    | Some(n) => int_of_string(n)
    | None => 0
    }

    <div className="appcode__grid">
      <div className="appcode__info">
        <div className="appcode__info2">
          <div onClick={_ => dispatch(GotoPreviousCard(countAll - countRemain - 2))}>
            <Icon.Arrow color=state.baseTextColor height=Constants.iconSize />
          </div>
          <div onClick={_ => dispatch(ShowSettingsMenu)}>
            <Icon.Settings color=state.settingsColor height=Constants.iconSize />
          </div>
          {state.showEnglish
            ? <div
                className="appcode__icon_rotate_back"
                onClick={_ => dispatch(SwitchEnglishShowing(currentCard.rus, shown))}>
                <Icon.Arrow color=state.baseTextColor height=Constants.iconSize />
              </div>
            : <div
                className="appcode__icon_rotate"
                onClick={_ => dispatch(SwitchEnglishShowing(currentCard.rus, shown))}>
                <Icon.Arrow color=state.englishTextColor height=Constants.iconSize />
              </div>}
          <div>
            <span onClick={_ => dispatch(GotoNextCard)}>
              {React.string(
                string_of_int(countAll - countRemain) ++ ("/" ++ string_of_int(countAll)),
              )}
            </span>
            <span className="appcode__eng_text_color">
              {React.string("(" ++ (string_of_int(shown) ++ ")"))}
            </span>
          </div>
          <div className="appcode__icon_invert__horizontal" onClick={_ => dispatch(GotoNextCard)}>
            <Icon.Arrow color=state.baseTextColor height=Constants.iconSize />
          </div>
        </div>
      </div>
      /* Russian field */
      <div
        className="appcode__russian"
        onClick={_ => dispatch(SwitchEnglishShowing(currentCard.rus, shown))}>
        <div className="appcode__center" key=currentCard.eng>
          <div className="appcode__scroll"> <div> {React.string(currentCard.rus)} </div> </div>
        </div>
      </div>
      /* English field */
      <div className="appcode__english" onClick={_ => speakEnglish(currentCard.eng)}>
        {state.showEnglish
          ? <div className="appcode__center">
              <div className="appcode__scroll">
                <div
                  className={"appcode__eng_text_color" ++ (
                    state.appcodeIsSpeaking ? " appcode__speaking" : ""
                  )}>
                  <div> {React.string(currentCard.eng)} </div>
                </div>
              </div>
            </div>
          : <div className="appcode__center" />}
      </div>
      {/* ************** */
      state.showSettings
        ? <PopUpSettingsMenu
            handleClosePopupClicked={_ => dispatch(HideSettingsMenu)}
            handleVoiceMenuClicked={event => {
              ReactEvent.Synthetic.stopPropagation(event)
              dispatch(ShowVoiceMenu)
            }}
            handleRestart={_ => dispatch(Restart)}
            baseTextColor=state.baseTextColor
            dangerColor=state.dangerColor
          />
        : <div />}
      {state.showVoiceMenu
        ? <PopUpVoiceMenu
            handleClosePopupClicked={_ => dispatch(HideVoiceMenu)}
            baseTextColor=state.baseTextColor
            voices=state.voices
          />
        : <div />}
    </div>
  }
}
