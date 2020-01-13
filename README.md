# Elm Quotes

A Elm Progressive Web App which display a list of quotes selected by DWYL: https://github.com/dwyl/quotes
The DWYL's quotes repository provide an Elixir and NPM packages.
This packages returned a map/json information, for example:

in Elixir the returned value is a map:
```elixir
%{
  "author" => "Peter Drucker",
  "text" => "The best way to predict your future is to create it."
}
```

in JavaScript the value is an object:
```js
{
  "author": "Peter Drucker",
  "text": "The best way to predict your future is to create it."
}
```

This elm-quotes application provides a user interface on top of the quotes raw information.
As this application is a PWA, you can choose to install it on your phone.
This will allow you to access all the quotes offline!

# Run it yourself

- Clone this repository: `git clone git@github.com:SimonLab/elm-quotes.git` and navigate to the project folder `cd elm-quotes`
- The Elm application is already compiled but if you add any changes to `src/Main.elm` you will need to recompile the application with:
`elm make src/Main.elm --output elm.js --optimize`
- Run the application with `elm reactor` and open the `index.html file