type state = {increaseOpacity: bool}
type action =
  | SetIncreaseOpacityTrue
  | ClosePopUpSettingsMenu

@react.component
let make = (
  ~handleClosePopupClicked,
  ~handleVoiceMenuClicked,
  ~handleRestart,
  ~baseTextColor,
  ~dangerColor,
) => {
  let (state, dispatch) = React.useReducer((_, action) =>
    switch action {
    | SetIncreaseOpacityTrue => {increaseOpacity: true}
    | ClosePopUpSettingsMenu =>
      Js.Global.setTimeout(handleClosePopupClicked, 1000) |> ignore
      {increaseOpacity: false}
    }
  , {increaseOpacity: false})
  React.useEffect0(() => {
    let _ = MyLib.requestAnimationFrame(_ => dispatch(SetIncreaseOpacityTrue))
    None
  })
  // let closePopUpSettingsMenu =
  Js.log("PopUpSettingsMenu render")
  <div
    className={state.increaseOpacity === true ? "popup__opacity_1" : "popup__opacity_0"}
    onClick={_ => dispatch(ClosePopUpSettingsMenu)}
    onDoubleClick={_ => dispatch(ClosePopUpSettingsMenu)}>
    <div className="popup__full_screen_div_opacity" />
    <div className="popup__full_screen_div">
      <div className="popup__window">
        <div className="popup__cancel">
          <Icon.Cancel color=baseTextColor height=Constants.iconSmallSize />
        </div>
        <div className="popup__list popup__row popup__header"> {React.string("settings:")} </div>
        <div className="popup__list">
          <PopUpMenuItem
            label="reset all"
            onClick={_ => {
              let _ = {
                open Dom.Storage
                clear(localStorage)
              }
              handleRestart()
              dispatch(ClosePopUpSettingsMenu)
            }}>
            <Icon.ClearAllInfo color=dangerColor height=Constants.iconSize />
          </PopUpMenuItem>
          <PopUpMenuItem
            label="dict #1"
            onClick={_ => {
              let _ = {
                open Dom.Storage
                localStorage |> removeItem(Constants.dict)
              }
              handleRestart()
              dispatch(ClosePopUpSettingsMenu)
            }}>
            <Icon.D1 color=dangerColor height=Constants.iconSize />
          </PopUpMenuItem>
          <PopUpMenuItem
            label="dict #2"
            onClick={_ => {
              let _ = {
                open Dom.Storage
                localStorage |> setItem(Constants.dict, "+")
              }
              handleRestart()
              dispatch(ClosePopUpSettingsMenu)
            }}>
            <Icon.D2 color=dangerColor height=Constants.iconSize />
          </PopUpMenuItem>
          <PopUpMenuItem label="voices" onClick=handleVoiceMenuClicked>
            <Icon.Voices color=dangerColor height=Constants.iconSize />
          </PopUpMenuItem>
        </div>
      </div>
    </div>
  </div>
}
