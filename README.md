# Carrot-Animate
Carrot-Animate is a [Love2D](https://love2d.org/) library for rendering Adobe Animate's Texture Atlas format.

With two different rendering modes, for personal preferences and different use cases.

___

## Details
**About rendering modes:**
- Direct Draw: Default, renders elements of a symbol directly into screen every frame.
- Canvas: Can be activated by calling the `makeCanvas` function, renders elements of a symbol into the configurated canvas and only redraws it when animation changes frame for better optimization.

___

## Known Issues
- [ ] Color Effects do not work (Tint, Alpha, Brightness, etc.)
- [ ] Looping modes other than "Play graphic in loop" do not work. (Play graphic once, Single frame, Reverse once, Reverse loop)
- [ ] Rotated frames will be displayed with a clockwise 90-degrees rotation.
- [ ] Blend modes do not work. (Add, Overlay, Multiply, etc.)
- [ ] Frame filters do not work (Blur, Shadow, etc.)
- [ ] Masks do not work.
- [ ] Children do not move according to the parent.
___

## Limitations
- Only Adobe Animate 2021 and forward work, this is due to the formatting being changed for being more compact, support for older versions may be added later on, but its not the main priority.
- On Direct Draw mode, sprite shaders may act weirdly as the shader affects every element of the animation individually, similar problem with opacity.
- On Canvas mode, sprites can be cut-off if the canvas is too small/offsets aren't properly adjusted.
___

## License

### Software

**Carrot-Animate** is licensed under the **MIT License**.
See [LICENSE](https://github.com/ShadowMario/Carrot-Animate/blob/main/LICENSE) for details.

___

## Third-Party Libraries
- [**json4lua**](http://github.com/craigmj/json4lua/) - Used only for the demo, JSON encoding/decoding @ **Craig Mason-Jones** - MIT License
