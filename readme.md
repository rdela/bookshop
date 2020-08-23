# Bookshop

An opinionated set of configurations for a multi-framework component library in Storybook.

## Usage

See the example folder. Currently split into:
`@bookshop/jekyll-engine`
`@bookshop/loader`

## TODO:
- Add generator as a package
- Glob all jekyll files into webpack and load through a custom FS implementation
- Move scss into scaless package
- Add ejs support
- Add Svelte support
- Add generic support by allowing custom templates to be provided to @bookshop/loader
- Abstract WebpackCopyPlugin
- Publish a bookshop package that handles everything including .storybook
- addDependency in @bookshop/loader to all files in the component's folder so webpack watches them (without bundling them)
- Figure out how to categorise frameworks within a component
