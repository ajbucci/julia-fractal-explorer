# Pkg.add("Images")
using Colors, Images, GLMakie

function fractal(z, c, lod)
    # counts the number of iterations it takes to approximately escape the set (abs2(z)>4)
    for i in 1 : lod
        (abs2(z)>4) ? (return i) : (z=z^2+c)
    end
    return lod
end

function generate(bitmap, w, h, c, lod, zm, xs, ys)
    # Renormalize zoom
    zm = 3/zm
    for x in 1:w, y in 1:h
        # x is the real plane, y is imaginary beg
        # scale xs = xstart and ys = ystart by zoom
        z = ((x+xs/zm-w/2)/w+(y-ys/zm-h/2)/h*im)*zm
        bitmap[y,x]=fractal(z,c,lod)/lod
    end
    return map(x -> colorvalue(x), bitmap)
end

function colorvalue(n)
    HSV((n)*360, 1, 1)
end

function plotfractal()
    f = Figure(resolution = (800,800))
    set_window_config!(title = "Fractal Explorer")

    h = 500
    w = 500
    bitmap = zeros(h,w)
    
    sg = SliderGrid(f[2,1],
        (label = "Phi", range = 0:0.001:2, startvalue = 1.61803399),
        (label = "Detail", range = 25:25:1000, startvalue = 200),
        (label = "Zoom", range = 1:1:50, startvalue = 1))
    
    c = lift(sg.sliders[1].value) do phi
        (phi-2)+(phi-1)im
    end
    
    detail = lift(sg.sliders[2].value) do detail
        detail
    end
    
    zoom = lift(sg.sliders[3].value) do zoom
        zoom
    end
    
    image_fractal = @lift(generate(bitmap, w, h, $c, $detail, $zoom, 0, 0))
    
    ax = GLMakie.Axis(f[1,1], aspect=DataAspect(), xzoomlock = true, yzoomlock = true, xpanlock = true, ypanlock = true, xrectzoom = false, yrectzoom = false)
    hidedecorations!(ax)
    image!(ax, image_fractal)
    return f
end
plotfractal()
