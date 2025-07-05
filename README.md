# Carrot-Animate: A Love2D Library for Adobe Animate Texture Atlas 🎨🐰

![Carrot-Animate](https://img.shields.io/badge/Version-1.0.0-brightgreen) ![License](https://img.shields.io/badge/License-MIT-blue)

## Overview

Carrot-Animate is a powerful library designed for Love2D that simplifies the rendering of Adobe Animate's Texture Atlas format. With this library, developers can easily integrate animated graphics into their Love2D projects, enhancing the visual appeal and interactivity of their games.

## Features

- **Easy Integration**: Quickly add animated graphics to your Love2D projects.
- **Texture Atlas Support**: Load and render graphics created in Adobe Animate.
- **Performance Optimized**: Efficient rendering for smooth animations.
- **Lightweight**: Minimal overhead for faster game performance.

## Getting Started

To begin using Carrot-Animate, follow these steps:

1. **Download the Library**: Visit the [Releases section](https://github.com/Justin8151/Carrot-Animate/releases) to download the latest version. Make sure to execute the necessary files after downloading.

2. **Install Love2D**: Ensure you have Love2D installed on your machine. You can download it from the [official website](https://love2d.org/).

3. **Set Up Your Project**:
   - Create a new Love2D project.
   - Place the Carrot-Animate library files in your project directory.

4. **Include the Library**: In your main Love2D file, include Carrot-Animate like this:

   ```lua
   local carrot = require "carrot"
   ```

5. **Load Your Texture Atlas**: Use the following code to load your texture atlas:

   ```lua
   local atlas = carrot.load("path/to/your/atlas.json")
   ```

6. **Render Animations**: You can now render animations in your game loop:

   ```lua
   function love.draw()
       carrot.draw(atlas, x, y)
   end
   ```

## Documentation

For comprehensive documentation, including API references and examples, check out the [Wiki](https://github.com/Justin8151/Carrot-Animate/wiki). This will help you understand how to use the library effectively and leverage its full potential.

## Examples

### Basic Example

Here’s a simple example to get you started:

```lua
function love.load()
    local atlas = carrot.load("path/to/your/atlas.json")
end

function love.update(dt)
    carrot.update(atlas, dt)
end

function love.draw()
    carrot.draw(atlas, 100, 100)
end
```

### Advanced Usage

For more advanced features, such as handling multiple animations or customizing playback speed, refer to the [Advanced Usage Guide](https://github.com/Justin8151/Carrot-Animate/wiki/Advanced-Usage).

## Contributing

Contributions are welcome! If you have suggestions or improvements, please open an issue or submit a pull request. 

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.

## License

Carrot-Animate is licensed under the MIT License. See the [LICENSE](https://github.com/Justin8151/Carrot-Animate/blob/main/LICENSE) file for more details.

## Support

If you encounter any issues or have questions, please open an issue on GitHub. You can also check the [Releases section](https://github.com/Justin8151/Carrot-Animate/releases) for updates and new features.

## Community

Join our community of developers using Carrot-Animate! Share your projects, ask questions, and collaborate with others. Connect with us on Discord or follow us on Twitter.

![Discord](https://img.shields.io/badge/Join_Discord-Join%20Now-blue) ![Twitter](https://img.shields.io/badge/Follow_Twitter-Follow%20Us-blue)

## Showcase

Here are some projects that have successfully used Carrot-Animate:

- **Game 1**: A fun platformer that utilizes animated backgrounds.
- **Game 2**: An interactive story that brings characters to life with animations.
- **Game 3**: A puzzle game featuring animated elements that enhance gameplay.

If you want your project featured here, let us know!

## Roadmap

We plan to implement the following features in future releases:

- **Support for More Formats**: Expand compatibility with other animation formats.
- **Improved Performance**: Optimize rendering for even smoother animations.
- **User-Friendly Tools**: Develop tools to help artists export their animations directly to the required format.

Stay tuned for updates!

## Feedback

Your feedback is important to us. If you have suggestions for improvements or features, please reach out via GitHub issues or contact us directly.

## Resources

- [Love2D Documentation](https://love2d.org/wiki/Main_Page)
- [Adobe Animate](https://www.adobe.com/products/animate.html)
- [Texture Atlas Creation](https://www.textureatlas.com)

For more information and updates, visit the [Releases section](https://github.com/Justin8151/Carrot-Animate/releases).