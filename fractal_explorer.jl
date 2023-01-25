# Pkg.add("Images")
using Colors, Images, GLMakie

function fractal(z, c, lod)
    # counts the number of iterations it takes to approximately escape the set (abs2(z)>4)
    for i in 1 : lod
        (abs2(z)>4) ? (return i) : (z=z^2+c)
    end
    return lod
end

function generate(bitmap, h, w, c, lod, zm, xs, ys)
    # Renormalize zoom
    zm = 3/zm
    for x in 1:w, y in 1:h
        # x is the real plane, y is imaginary beg
        # scale xs = xstart and ys = ystart by zoom
        z = ((x+xs/zm-w/2)/w+(y-ys/zm-h/2)/h*im)*zm
        bitmap[x,y]=fractal(z,c,lod)/lod
    end
    return map(x -> colorvalue(x), bitmap)
end

function colorvalue(n)
    HSV((n)*360, 1, 1)
end

function plotfractal()
    f = Figure(resolution = (800,800))
    set_window_config!(title = "Fractal Explorer")

    h = 1000
    w = 1000
    bitmap = zeros(h,w)
    
    p_input = f[2 , 1]
    p_nav = f[2, 2]

    
    zoom = Observable(1.0)
    zoom_text = Textbox(p_input[2,2], placeholder = "Zoom",
        validator = Float64, tellwidth = false)
    zoom_label = Label(p_input[2,4], string(zoom[]))
 
    on(zoom_text.stored_string) do s
        zoom[] = parse(Float64, s)
    end

    detail_text = Textbox(p_input[3,2], placeholder = "Detail",
    validator = Int64, tellwidth = false)
    detail = Observable(200)
    on(detail_text.stored_string) do s
        detail[] = parse(Float64, s)
    end

    sg = SliderGrid(p_input[1,1:3],
        (label = "Phi", range = 0:0.001:2, startvalue = 1.61803399))
    
    zoom_up = Button(p_input[2,3], label = "++")
    zoom_down = Button(p_input[2,1], label = "--")
    on(zoom_up.clicks) do _
        zoom[] = zoom[]*1.25
        zoom_label.text[] = string(round(zoom[]; digits=2))
    end
    on(zoom_down.clicks) do _
        zoom[] = max(zoom[]*.75,1.0)
        zoom_label.text[] = string(round(zoom[]; digits=2))
    end

    x_up = Button(p_nav[2,3], label =">")
    x_down = Button(p_nav[2,1], label ="<")
    x_offset = Observable(0.0)
    on(x_up.clicks) do _
        x_offset[] = x_offset[] + 100/zoom[]
    end
    on(x_down.clicks) do _
        x_offset[] = x_offset[] - 100/zoom[]
    end

    y_up = Button(p_nav[1,2], label ="^")
    y_down = Button(p_nav[3,2], label ="v")
    y_offset = Observable(0.0)
    on(y_up.clicks) do _
        y_offset[] = y_offset[] - 100/zoom[]
    end
    on(y_down.clicks) do _
        y_offset[] = y_offset[] + 100/zoom[]
    end

    xy_center = Button(p_nav[2,2], label = "0,0")
    on(xy_center.clicks) do _
        y_offset[] = 0
        x_offset[] = 0
    end

    c = lift(sg.sliders[1].value) do phi
        (phi-2)+(phi-1)im
    end
    
    image_fractal = @lift(generate(bitmap, w, h, $c, $detail, $zoom, $x_offset, $y_offset))
    
    ax = GLMakie.Axis(f[1,1:2], aspect=DataAspect(), xzoomlock = true, yzoomlock = true, xpanlock = true, ypanlock = true, xrectzoom = false, yrectzoom = false)
    hidedecorations!(ax)
    image!(ax, image_fractal)
    return f
end
plotfractal()
