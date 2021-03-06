require 'test_helper'

class RtlizerTest < ActiveSupport::TestCase
  def assert_declaration_transformation(from, to, one_way = false)
    assert_equal(to, Rtlize::Declaration.transform_multiple(from))
    assert_equal(from, Rtlize::Declaration.transform_multiple(to)) unless one_way
  end

  def assert_no_declaration_transformation(css)
    assert_equal(css, Rtlize::Declaration.transform_multiple(css))
  end

  def assert_transformation(from, to, one_way = false)
    assert_equal(to, Rtlize::RTLizer.transform(from))
    assert_equal(from, Rtlize::RTLizer.transform(to)) unless one_way
  end

  def assert_no_transformation(css)
    assert_equal(css, Rtlize::RTLizer.transform(css))
  end

  test "Should transform the border properties properly" do
    assert_declaration_transformation("border-left: 1px solid red;", "border-right: 1px solid red;")

    assert_declaration_transformation("border-left-color: red;",   "border-right-color: red;")
    assert_declaration_transformation("border-left-style: solid;", "border-right-style: solid;")
    assert_declaration_transformation("border-left-width: 1px;",   "border-right-width: 1px;")

    assert_declaration_transformation("border-color: #111 #222 #333 #444;",        "border-color: #111 #444 #333 #222;")
    assert_declaration_transformation("border-style: dotted solid double dashed;", "border-style: dotted dashed double solid;")
    assert_declaration_transformation("border-width: 1px 2px 3px 4px;",            "border-width: 1px 4px 3px 2px;")
  end

  test "Should transform the border-radius property" do
    ["border-radius", "-moz-border-radius", "-webkit-border-radius"].each do |prop|
      assert_declaration_transformation(   "#{prop}: 1px 2px 3px 4px;", "#{prop}: 2px 1px 4px 3px;")
      assert_declaration_transformation(   "#{prop}: 1px 2px 3px;",     "#{prop}: 2px 1px 2px 3px;", true)
      assert_declaration_transformation(   "#{prop}: 1px 2px;",         "#{prop}: 2px 1px;")
      assert_no_declaration_transformation("#{prop}: 1px;")
    end

    ['top', 'bottom'].each do |side|
      assert_declaration_transformation("border-#{side}-left-radius:         1px;", "border-#{side}-right-radius:         1px;")
      assert_declaration_transformation("-moz-border-radius-#{side}left:     1px;", "-moz-border-radius-#{side}right:     1px;")
      assert_declaration_transformation("-webkit-border-#{side}-left-radius: 1px;", "-webkit-border-#{side}-right-radius: 1px;")
    end
  end

  test "Should transform the box-shadow properties" do
    ["box-shadow", "-moz-box-shadow", "-webkit-box-shadow"].each do |prop|
      assert_declaration_transformation("#{prop}: #000 1px -2px, rgba(10, 20, 30) 4px 5px;", "#{prop}: #000 -1px -2px, rgba(10, 20, 30) -4px 5px;")
      assert_declaration_transformation("#{prop}: inset -1px 2px 3px #FFFFFF, -4px 5px 6px black;", "#{prop}: inset 1px 2px 3px #FFFFFF, 4px 5px 6px black;")
      assert_declaration_transformation("#{prop}: 1px 2px 3px rgba(20, 40, 60, 0.5) inset;", "#{prop}: -1px 2px 3px rgba(20, 40, 60, 0.5) inset;")
      assert_declaration_transformation("#{prop}: -1px -2px 3px #000 inset;", "#{prop}: 1px -2px 3px #000 inset;")

      # Test when value is zero
      assert_no_declaration_transformation("#{prop}: 0px 2px 3px red;")
      assert_no_declaration_transformation("#{prop}: 0 2px 3px red;")
      assert_no_declaration_transformation("#{prop}: -00 2px 3px red;")

      # Test for different numeral values.
      assert_declaration_transformation("#{prop}: 001px  2px 3px red;", "#{prop}: -001px  2px 3px red;")
      assert_declaration_transformation("#{prop}: 1.5px  2px 3px red;", "#{prop}: -1.5px  2px 3px red;")
      assert_declaration_transformation("#{prop}: 0.5px  2px 3px red;", "#{prop}: -0.5px  2px 3px red;")
      assert_declaration_transformation("#{prop}: .5px   2px 3px red;", "#{prop}: -.5px   2px 3px red;")
      assert_declaration_transformation("#{prop}: 5.55px 2px 3px red;", "#{prop}: -5.55px 2px 3px red;")
    end
  end

  test "Should transform the clear/float properties" do
    assert_declaration_transformation("clear: left;", "clear: right;")
    assert_declaration_transformation("float: left;", "float: right;")
  end

  test "Should transform the clip property" do
    assert_declaration_transformation("clip: rect(1px, 2px, 3px, 4px);", "clip: rect(1px, 4px, 3px, 2px);")
    assert_declaration_transformation("clip: rect(1px 2px 3px 4px);",    "clip: rect(1px 4px 3px 2px);")
    assert_no_declaration_transformation("clip: auto;")
  end

  test "Should transform the cursor property" do
    assert_declaration_transformation("cursor: e-resize;",  "cursor: w-resize;")
    assert_declaration_transformation("cursor: ne-resize;", "cursor: nw-resize;")
    assert_declaration_transformation("cursor: se-resize;", "cursor: sw-resize;")
    assert_no_declaration_transformation("cursor: pointer;")
  end

  test "Should transform the direction property" do
    assert_declaration_transformation("direction: ltr;", "direction: rtl;")
  end

  test "Should transform the left/right position properties" do
    assert_declaration_transformation("left: 1px;", "right: 1px;")
  end

  test "Should transform the margin property" do
    assert_declaration_transformation("margin: 1px 2px 3px 4px;", "margin: 1px 4px 3px 2px;")
    assert_declaration_transformation("margin-left: 1px;", "margin-right: 1px;")
  end

  test "Should transform the padding property" do
    assert_declaration_transformation("padding: 1px 2px 3px 4px;", "padding: 1px 4px 3px 2px;")
    assert_declaration_transformation("padding-left: 1px;", "padding-right: 1px;")
  end

  test "Should transform the rotation property" do
    assert_declaration_transformation("rotation: 0;", "rotation: 0;")
    assert_declaration_transformation("rotation: 360deg;", "rotation: 0deg;")
    assert_declaration_transformation("rotation: 270deg;", "rotation: 90deg;")
    assert_declaration_transformation("rotation: 200.5deg;", "rotation: 159.5deg;")
    assert_no_declaration_transformation("rotation: 180deg;")
  end

  test "Should transform the text-align property" do
    assert_declaration_transformation("text-align: left;", "text-align: right;")
  end

  test "Should transform the text-shadow property" do
    ["text-shadow", "-moz-text-shadow", "-webkit-text-shadow"].each do |prop|
      assert_declaration_transformation("#{prop}: #000 1px -2px, rgba(10, 20, 30) 4px 5px;", "#{prop}: #000 -1px -2px, rgba(10, 20, 30) -4px 5px;")
      assert_declaration_transformation("#{prop}: -1px 2px 3px #FFFFFF, -4px 5px 6px black;", "#{prop}: 1px 2px 3px #FFFFFF, 4px 5px 6px black;")
      assert_declaration_transformation("#{prop}: 1px 2px 3px rgba(20, 40, 60, 0.5);", "#{prop}: -1px 2px 3px rgba(20, 40, 60, 0.5);")
      assert_declaration_transformation("#{prop}: -1px -2px 3px #000;", "#{prop}: 1px -2px 3px #000;")
    end
  end

  test "Should properly handle DATA URI schemes" do
    checked_box = <<-CSS
      background: white url('data:image/png;base64,iVBORw0KGgoAA
        AANSUhEUgAAABAAAAAQAQMAAAAlPW0iAAAABlBMVEUAAAD///+l2Z/dAAAAM0l
        EQVR4nGP4/5/h/1+G/58ZDrAz3D/McH8yw83NDDeNGe4Ug9C9zwz3gVLMDA/A6
        P9/AFGGFyjOXZtQAAAAAElFTkSuQmCC') no-repeat;
    CSS
    assert_no_declaration_transformation(checked_box)
  end

  test "Should transform properties with IE hacks" do
    assert_declaration_transformation("_float: left;", "_float: right;")
    assert_declaration_transformation("*float: left;", "*float: right;")
    assert_declaration_transformation('float: left\9;', 'float: right\9;')
    assert_declaration_transformation('float: left \9;', 'float: right \9;')
  end

  test "Should transform !important rules properly" do
    ['!important', '! important'].each do |imp_txt|
      assert_declaration_transformation("float: left #{imp_txt};", "float: right #{imp_txt};")
      assert_declaration_transformation("direction: ltr #{imp_txt};", "direction: rtl #{imp_txt};")
      assert_declaration_transformation("cursor: e-resize #{imp_txt};", "cursor: w-resize #{imp_txt};")
      assert_declaration_transformation("rotation: 90deg #{imp_txt};", "rotation: 270deg #{imp_txt};")
      assert_declaration_transformation("margin: 1px 2px 3px 4px #{imp_txt};", "margin: 1px 4px 3px 2px #{imp_txt};")
      assert_declaration_transformation("clip: rect(1px, 2px, 3px, 4px) #{imp_txt};", "clip: rect(1px, 4px, 3px, 2px) #{imp_txt};")
      assert_declaration_transformation("border-radius: 1px 2px 3px 4px #{imp_txt};", "border-radius: 2px 1px 4px 3px #{imp_txt};")
      assert_declaration_transformation("box-shadow: -1px -2px 3px #000 inset #{imp_txt};", "box-shadow: 1px -2px 3px #000 inset #{imp_txt};")
    end
  end

  test "Should not transform CSS rules whose selector uses the rtl_selector" do
    default_rtl_selector = Rtlize.rtl_selector

    [default_rtl_selector, '[dir="rtl"]', "[dir='rtl']"].each do |rtl_selector|
      Rtlize.rtl_selector = rtl_selector
      assert_no_transformation("[dir=rtl]   .klass span #id { float: left; }")
      assert_no_transformation("[dir='rtl'] .klass span #id { float: left; }")
      assert_no_transformation('[dir="rtl"] .klass span #id { float: left; }')
    end

    Rtlize.rtl_selector = '.rtl'
    assert_no_transformation('.rtl .klass span #id { float: left; }')

    Rtlize.rtl_selector = default_rtl_selector
  end

  test "Should transform properties without semicolons properly" do
    assert_transformation('.test { float: left }', '.test { float: right }')
  end

  test "Should not transform CSS marked with no-rtl" do
    assert_no_transformation(<<-CSS)
      /*!= begin(no-rtl) */

      .klass { float: left; }

      /*!= end(no-rtl) */
    CSS

    before = <<-CSS
      .klass-1 { float: left; }

      /*!= begin(no-rtl) */

      .klass-2 { float: left; }

      /*!= end(no-rtl) */

      .klass-3 { float: left; }
    CSS

    after = <<-CSS
      .klass-1 { float: right; }

      /*!= begin(no-rtl) */

      .klass-2 { float: left; }

      /*!= end(no-rtl) */

      .klass-3 { float: right; }
    CSS

    assert_transformation(before, after)
  end

  test "Should respect no-rtl markers even if first selector after them is ignored" do
    before = <<-CSS
      /*!= begin(no-rtl) */

      [dir=rtl] .klass { float: left; }

      .klass-2 { float: left; }

      /*!= end(no-rtl) */

      [dir=rtl] .klass-3 { float: left; }

      .klass-4 { float: left; }
    CSS

    after = <<-CSS
      /*!= begin(no-rtl) */

      [dir=rtl] .klass { float: left; }

      .klass-2 { float: left; }

      /*!= end(no-rtl) */

      [dir=rtl] .klass-3 { float: left; }

      .klass-4 { float: right; }
    CSS

    assert_transformation(before, after)
  end

  test "Should handle multiline CSS properly" do
    assert_no_transformation(<<-CSS)
      @font-face {
        font-family: 'MyFont';
        src: font-url('myfont/myfont.eot');
        src: font-url('myfont/myfont.eot?#iefix') format('embedded-opentype'),
             font-url('myfont/myfont.woff') format('woff'),
             font-url('myfont/myfont.ttf') format('truetype'),
             font-url('myfont/myfont.svg#myfont') format('svg');
        font-weight: normal;
        font-style: normal;
      }
    CSS
  end

  test "Should properly handle @-rules that don't take blocks correctly" do
    assert_no_transformation("@import 'custom.css';")
    assert_transformation("@import 'custom.css'; .klass { float: left; }", "@import 'custom.css'; .klass { float: right; }")
  end

  test "Should properly handle nested blocks" do
    before = <<-CSS
      @media print {
        .test {
          margin-right: 10px;
        }

        @media (max-width: 600px) {
          .test {
            float: right;
          }

          @media (max-height: 600px) {
            .test {
              padding-right: 5px;
            }
          }
        }
      }
    CSS

    after = <<-CSS
      @media print {
        .test {
          margin-left: 10px;
        }

        @media (max-width: 600px) {
          .test {
            float: left;
          }

          @media (max-height: 600px) {
            .test {
              padding-left: 5px;
            }
          }
        }
      }
    CSS

    assert_transformation(before, after)
  end

  test "Should properly transform animations" do
    before = <<-CSS
      @keyframes slidein {
        from {
          margin-left: 100%;
        }

        100% {
          margin-left: 0%;
        }
      }
    CSS

    after = <<-CSS
      @keyframes slidein {
        from {
          margin-right: 100%;
        }

        100% {
          margin-right: 0%;
        }
      }
    CSS

    assert_transformation(before, after)
  end

  test "Should handle media queries correctly" do
    before = <<-CSS
    @media (max-width: 600px) {
      .klass-1 {
        float: left;
      }

      .klass-2 {
        float: left;
      }
    }

    .klass-3 {
      float: left;
    }
    CSS

    after = <<-CSS
    @media (max-width: 600px) {
      .klass-1 {
        float: right;
      }

      .klass-2 {
        float: right;
      }
    }

    .klass-3 {
      float: right;
    }
    CSS

    assert_transformation(before, after)
  end
end
