type state = {increaseOpacity: bool}
type action =
  | SetIncreaseOpacityTrue
  | ClosePopUpSettingsMenu
let initialState = {increaseOpacity: false}

@react.component
let make = (~handleClosePopupClicked, ~baseTextColor, ~voices) => {
  let (state, dispatch) = React.useReducer((_, action) =>
    switch action {
    | SetIncreaseOpacityTrue => {increaseOpacity: true}

    | ClosePopUpSettingsMenu =>
      Js.Global.setTimeout(handleClosePopupClicked, 1000) |> ignore
      {increaseOpacity: false}
    }
  , initialState)

  React.useEffect0(() => {
    let _ = MyLib.requestAnimationFrame(_ => dispatch(SetIncreaseOpacityTrue))
    None
  })

  Js.log("PopUpVoiceMenu render")
  let fVoices =
    voices
    |> Array.to_list
    |> List.mapi((i, voice) => {
      let lang: string = SpeechSynthesis.Voice.langGet(voice)
      let name: string = SpeechSynthesis.Voice.nameGet(voice)
      (i, lang ++ (" " ++ name))
    })
    |> List.filter(((_, name)) => String.sub(name, 0, 2) === "en")
    |> List.sort(((_, name1), (_, name2)) => name1 > name2 ? 1 : -1)

  let currentVoiceIndex = MyLib.getVoiceIndex()

  Js.log2("didMount fVoices=", fVoices)

  <div
    className={state.increaseOpacity === true
      ? "popup__opacity_1 popup_voices_zindex"
      : "popup__opacity_0 popup_voices_zindex"}
    onClick={_ => dispatch(ClosePopUpSettingsMenu)}
    onDoubleClick={_ => dispatch(ClosePopUpSettingsMenu)}>
    <div className="popup__full_screen_div_opacity" />
    <div className="popup__full_screen_div">
      <div className="popup__window popup__scroll">
        <div className="popup__cancel">
          <Icon.Cancel color=baseTextColor height=Constants.iconSmallSize />
        </div>
        <div className="popup__list popup__row popup__header"> {React.string("voices:")} </div>
        <div className="popup__list">
          {fVoices
          |> List.map(((index, name)) =>
            <div
              key={string_of_int(index)}
              className={"popup__row" ++ (
                index === currentVoiceIndex ? " popup__row_selected" : ""
              )}
              onClick={_ => {
                {
                  open Dom.Storage
                  localStorage |> setItem(Constants.voiceIndexTeg, string_of_int(index))
                }

                handleClosePopupClicked()
              }}>
              <div> {React.string(name)} </div>
            </div>
          )
          |> Array.of_list
          |> React.array}
        </div>
      </div>
    </div>
  </div>
}
