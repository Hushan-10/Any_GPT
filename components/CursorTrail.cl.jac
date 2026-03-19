"""Cursor trail — canvas-based star-shaped particle effect with orange glow."""

import from react { useEffect, useRef }


"""Full-screen canvas overlay that renders star-shaped particles trailing the cursor."""
def:pub CursorTrail() -> any {
    canvasRef = useRef(None);
    particlesRef = useRef([]);
    animationRef = useRef(0);

    useEffect(lambda -> None {
        canvas = canvasRef.current;
        if canvas {
            ctx = canvas.getContext("2d");
            if ctx {
                canvas.width = window.innerWidth;
                canvas.height = window.innerHeight;

                onResize = lambda -> None {
                    canvas.width = window.innerWidth;
                    canvas.height = window.innerHeight;
                };

                onMouseMove = lambda e: any -> None {
                    count = Math.floor(Math.random() * 3) + 1;
                    idx = 0;
                    while idx < count and particlesRef.current.length < 250 {
                        particlesRef.current.push({
                            "x": e.clientX,
                            "y": e.clientY,
                            "size": Math.random() * 3 + 1,
                            "alpha": Math.random() * 0.5 + 0.5,
                            "decay": Math.random() * 0.02 + 0.015,
                            "offsetX": (Math.random() - 0.5) * 20,
                            "offsetY": (Math.random() - 0.5) * 20
                        });
                        idx = idx + 1;
                    }
                };

                animate = lambda -> None {
                    ctx.clearRect(0, 0, canvas.width, canvas.height);
                    kept = [];

                    for p in particlesRef.current {
                        p.alpha = p.alpha - p.decay;
                        if p.alpha > 0 {
                            ctx.save();
                            ctx.globalAlpha = p.alpha;
                            ctx.fillStyle = "#FF6B35";
                            ctx.shadowBlur = p.size * 4;
                            ctx.shadowColor = "rgba(255, 140, 90, 0.6)";

                            drawX = p.x + p.offsetX * (1 - p.alpha);
                            drawY = p.y + p.offsetY * (1 - p.alpha);

                            ctx.beginPath();
                            outerR = p.size;
                            innerR = p.size * 0.4;
                            j = 0;
                            while j < 8 {
                                r = (outerR if j % 2 == 0 else innerR);
                                angle = (j * Math.PI) / 4 - Math.PI / 2;
                                px = drawX + Math.cos(angle) * r;
                                py = drawY + Math.sin(angle) * r;
                                if j == 0 {
                                    ctx.moveTo(px, py);
                                } else {
                                    ctx.lineTo(px, py);
                                }
                                j = j + 1;
                            }
                            ctx.closePath();
                            ctx.fill();
                            ctx.restore();

                            kept.push(p);
                        }
                    }

                    particlesRef.current = kept;
                    animationRef.current = requestAnimationFrame(animate);
                };

                window.addEventListener("resize", onResize);
                window.addEventListener("mousemove", onMouseMove);
                animate();
            }
        }
    }, []);

    return <canvas
        ref={canvasRef}
        style={{
            "position": "fixed",
            "top": "0",
            "left": "0",
            "width": "100vw",
            "height": "100vh",
            "zIndex": "9999",
            "pointerEvents": "none"
        }}
    />;
}
