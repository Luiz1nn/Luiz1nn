import CoreGraphics
import CoreText
import Foundation

guard CommandLine.arguments.count == 5 else {
  fatalError("Usage: swift scripts/build-banner.swift Archivo-SemiBold.ttf Archivo-Regular.ttf JetBrainsMono-Regular.ttf assets")
}

func loadFont(_ path: String) -> CGFont {
  guard let provider = CGDataProvider(url: URL(fileURLWithPath: path) as CFURL),
        let font = CGFont(provider) else { fatalError("Cannot load font: \(path)") }
  return font
}

let headingFont = loadFont(CommandLine.arguments[1])
let bodyFont = loadFont(CommandLine.arguments[2])
let monoFont = loadFont(CommandLine.arguments[3])
precondition((headingFont.postScriptName as String? ?? "").contains("Archivo"))
precondition((bodyFont.postScriptName as String? ?? "").contains("Archivo"))
precondition((monoFont.postScriptName as String? ?? "").contains("JetBrainsMono"))

func number(_ value: CGFloat) -> String {
  precondition(value.isFinite)
  return String(format: "%.2f", Double(abs(value) < 0.005 ? 0 : value))
}

func geometry(_ path: CGPath) -> String {
  var parts: [String] = []
  path.applyWithBlock { pointer in
    let element = pointer.pointee
    let p = element.points
    func point(_ i: Int) -> String { "\(number(p[i].x)) \(number(p[i].y))" }
    switch element.type {
    case .moveToPoint: parts.append("M\(point(0))")
    case .addLineToPoint: parts.append("L\(point(0))")
    case .addQuadCurveToPoint: parts.append("Q\(point(0)) \(point(1))")
    case .addCurveToPoint: parts.append("C\(point(0)) \(point(1)) \(point(2))")
    case .closeSubpath: parts.append("Z")
    @unknown default: fatalError("Unsupported path element")
    }
  }
  return parts.joined(separator: " ")
}

func line(_ text: String, font: CGFont, size: CGFloat, tracking: CGFloat = 0) -> CTLine {
  let attributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithGraphicsFont(font, size, nil, nil),
    NSAttributedString.Key(kCTKernAttributeName as String): tracking,
  ]
  return CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
}

func textPath(_ text: String, font: CGFont, size: CGFloat, x: CGFloat, y: CGFloat,
              maxWidth: CGFloat, fill: String, tracking: CGFloat = 0) -> String {
  let shaped = line(text, font: font, size: size, tracking: tracking)
  let width = CGFloat(CTLineGetTypographicBounds(shaped, nil, nil, nil))
  precondition(width <= maxWidth + 0.1, "Text overflows: \(text) (\(width) > \(maxWidth))")
  let combined = CGMutablePath()
  for run in CTLineGetGlyphRuns(shaped) as! [CTRun] {
    let count = CTRunGetGlyphCount(run)
    var glyphs = [CGGlyph](repeating: 0, count: count)
    var positions = [CGPoint](repeating: .zero, count: count)
    CTRunGetGlyphs(run, CFRange(location: 0, length: count), &glyphs)
    CTRunGetPositions(run, CFRange(location: 0, length: count), &positions)
    let attributes = CTRunGetAttributes(run) as NSDictionary
    let runFont = attributes[kCTFontAttributeName] as! CTFont
    for i in 0..<count {
      guard let path = CTFontCreatePathForGlyph(runFont, glyphs[i], nil) else { continue }
      let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1,
                                       tx: x + positions[i].x, ty: y - positions[i].y)
      combined.addPath(path, transform: transform)
    }
  }
  precondition(combined.boundingBox.minY >= 0 && combined.boundingBox.maxY <= 288)
  return "<path fill=\"\(fill)\" d=\"\(geometry(combined))\"/>"
}

let output = URL(fileURLWithPath: CommandLine.arguments[4], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

let background = "#0a0a0a"
let foreground = "#f5f5f5"
let muted = "#8a8a8a"
let border = "#262626"
for mobile in [false, true] {
  let width: CGFloat = mobile ? 360 : 800
  let padding: CGFloat = mobile ? 20 : 32
  let available = width - padding * 2
  let top: CGFloat = mobile ? 28 : 34
  let divider: CGFloat = mobile ? 48 : 54
  let stamp = "ENGINEERING / PORTFOLIO"
  let stampSize: CGFloat = 11
  let stampWidth = CGFloat(CTLineGetTypographicBounds(line(stamp, font: monoFont, size: stampSize), nil, nil, nil))
  var nodes = [
    "<rect width=\"\(Int(width))\" height=\"288\" fill=\"var(--background)\"/>",
    "<path d=\"M\(number(padding)) \(number(divider))H\(number(width-padding))\" stroke=\"var(--border)\"/>",
    "<rect x=\"\(number(padding+27))\" y=\"\(number(top-8))\" width=\"5\" height=\"5\" fill=\"#b7ff64\"/>",
    textPath("LF", font: monoFont, size: 14, x: padding, y: top, maxWidth: 24, fill: "var(--foreground)"),
    textPath(stamp, font: monoFont, size: stampSize, x: width-padding-stampWidth, y: top, maxWidth: available-60, fill: "var(--muted-foreground)"),
    textPath("Luis Fernando", font: headingFont, size: mobile ? 32 : 44, x: padding, y: mobile ? 96 : 112, maxWidth: available, fill: "var(--foreground)", tracking: mobile ? -1.2 : -1.7),
    textPath("Full-Stack Software Engineer · 5+ years", font: monoFont, size: 12, x: padding, y: mobile ? 120 : 140, maxWidth: available, fill: "var(--muted-foreground)"),
    textPath("Brazil · Remote", font: monoFont, size: 12, x: padding, y: mobile ? 140 : 160, maxWidth: available, fill: "var(--muted-foreground)"),
  ]
  let headline = mobile
    ? ["I build products that", "organize operations and", "automate processes."]
    : ["I build products that organize", "operations and automate processes."]
  for (index, text) in headline.enumerated() {
    nodes.append(textPath(text, font: bodyFont, size: mobile ? 28 : 34,
                          x: padding, y: (mobile ? 190 : 214) + CGFloat(index) * (mobile ? 32 : 40),
                          maxWidth: available, fill: "var(--foreground)", tracking: mobile ? -0.7 : -0.85))
  }
  let svg = """
  <svg xmlns="http://www.w3.org/2000/svg" width="\(Int(width))" height="288" viewBox="0 0 \(Int(width)) 288" role="img" aria-labelledby="title description">
  <title id="title">Luis Fernando — Full-Stack Software Engineer</title>
  <desc id="description">I build products that organize operations and automate processes. Brazil · Remote. Typography: Archivo and JetBrains Mono, converted to vector paths.</desc>
  <style>
  :root{--background:\(background);--foreground:\(foreground);--muted-foreground:\(muted);--border:\(border)}
  @media(prefers-color-scheme:light){:root{--background:#fafafa;--foreground:#111111;--muted-foreground:#696969;--border:#dedede}}
  @media(prefers-color-scheme:dark){:root{--background:#0a0a0a;--foreground:#f5f5f5;--muted-foreground:#8a8a8a;--border:#262626}}
  </style>
  \(nodes.joined(separator: "\n"))
  </svg>
  """
  let filename = "profile-hero-\(mobile ? "mobile" : "desktop").svg"
  try (svg + "\n").write(to: output.appendingPathComponent(filename), atomically: true, encoding: .utf8)
  print("Generated \(filename)")
}
