@react.component
let make = (~label, ~onClick, ~children) =>
  <div className="popup__row" onClick onDoubleClick=onClick>
    <div className="popup__width35"> children </div>
    <div className="popup__gap" />
    <div> {React.string(label)} </div>
  </div>
