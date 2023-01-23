# Pkg.add("Images")
using Colors, Images

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
    return bitmap
end

function colorvalue(n)
    HSV((n)*360, 1, 1)
end

detail = 200; h = 3000; w = 3000; phi = 1.61803399; zoom = 2; xpos = 25; ypos = 35;
bitmap = zeros(h,w)
c = (phi-2)+(phi-1)im
image = generate(bitmap, w, h, c, detail, zoom, xpos, ypos)
map(x -> colorvalue(x),image)
# HSV.(image)
