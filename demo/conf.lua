function love.conf(t)
	t.window.resizable = false
	t.accelerometerjoystick = false

	t.window.title = "Carrot-Animate"
	t.window.identity = "carrot-animate"
	t.identity = "Carrot-Animate"
	t.console = true
	t.release = false

	t.modules.physics = false
	t.modules.video = false
	t.modules.thread = false
	t.modules.event = true
	t.modules.timer = true
	t.modules.mouse = false

	t.window.width = 640
	t.window.height = 360
	t.window.vsync = false
	t.window.usedpiscale = false
end