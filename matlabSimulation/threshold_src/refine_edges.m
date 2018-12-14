function NewQuad = refine_edges(image, quad)
lines = zeros(4,4); %For each line [Ex, Ey, nx, ny]
for edge = 1:4
	a = edge; b = (floor(mod(edge,4))+1);
	
	nx =  quad(b,2) - quad(a,2);
	ny = -quad(b,1) + quad(a,1);
	mag = sqrt(nx*nx + ny*ny);
	nx = nx / mag;
	ny = ny / mag;
	
	nsamples = max(16, floor(mag/8));
	
	for s = 1:nsamples
	alpha = (1 + s) / (nsamples + 1);
	x0 = alpha*quad(a,1) + (1-alpha)*quad(b,1);
	y0 = alpha*quad(a,2) + (1-alpha)*quad(b,2);
	
	Mn = 0;
	Mcount = 0;
	
	range = 1;
		for n = -range:0.25:range
			grange = 1;
			x1 = floor(x0 + (n + grange)*nx);
			y1 = floor(y0 + (n + grange)*ny);
			
			if( x1 < 1 || x1 > width || y1 < 1 || y1 > height)
				continue;
			end
			
			x2 = floor(x0 + (n - grange)*nx);
			y2 = floor(y0 + (n - grange)*ny);
			
			if( x2 < 1 || x2 > width || y2 < 1 || y2 > height)
				continue;
			end
			
			g1 = image(y1,x1);
			g2 = image(y2,x2);
			
			if(g1 < g2)
				continue; %Oops the gradient is backwards. Reject this point
			end
			
			weight = (g2 - g1)*(g2 - g1); %Shapes the weight weight=f(g2-g1)
			
			Mn = Mn + (weight*n);
			Mcount = Mcount + weight;
		end
	end
	
	if(Mcount == 0)
		continue; %We have no points!
	end
	
	bestx = x0 + n0*nx;
	besty = y0 + n0*ny;
	
	Mx = Mx + bestx;
	My = My + besty;
	Mxx = Mxx + (bestx*bestx);
	Mxy = Mxy + (bestx*besty);
	Myy = Myy + (besty*besty);
	N = N + 1;
	end
end

end