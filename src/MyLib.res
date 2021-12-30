let rec takeItems = (n, list) =>
  switch (n, list) {
  | (_, list{}) => list{}
  | (0, _) => list{}
  | (_, list{x, ...tail}) => list{x, ...takeItems(n - 1, tail)}
  }

let rec dropItems = (n, list) =>
  switch (n, list) {
  | (_, list{}) => list{}
  | (0, _) => list
  | (_, list{_, ...tail}) => dropItems(n - 1, tail)
  }

let getVoiceIndex = () =>
  switch {
    open Dom.Storage
    localStorage |> getItem(Constants.voiceIndexTeg)
  } {
  | Some(n) => int_of_string(n)
  | None => -1
  }

@val
external requestAnimationFrame: (unit => unit) => float = "requestAnimationFrame"

let getColorsFromCSS: unit => (string, string, string, string) = () => (
  %raw(` getComputedStyle(document.documentElement).getPropertyValue("--base-text-color") `),
  %raw(` getComputedStyle(document.documentElement).getPropertyValue("--settings-color") `),
  %raw(` getComputedStyle(document.documentElement).getPropertyValue("--english-text-color") `),
  %raw(` getComputedStyle(document.documentElement).getPropertyValue("--danger-color") `),
)

// let aaa = () => 10
