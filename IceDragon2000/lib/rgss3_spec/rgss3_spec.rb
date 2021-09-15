module Boolean
end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end

def main_object
  self
end

module Moon
  module Test
    module Assert
      # just a varitaion of assert_equal
      def assert_equal_default(expected, actual)
        assert_equal(expected, actual, "expected #{expected.inspect} as default, but actual is #{actual.inspect}.")
      end

      # Checks if the object was disposed
      def assert_disposed(obj, msg = nil)
        assert_true(obj.disposed?, msg || "expected #{obj.inspect} to be disposed.")
      end

      # @param [Array<Integer>[4], Color] c1
      # @param [Color] c2
      def assert_equal_color(c1, c2, msg = nil)
        c1 = [c1.red, c1.green, c1.blue, c1.alpha] unless c1.is_a?(Array)
        assert_kind_of(Color, c2)
        assert_equal(c1[0], c2.red,   "expected red to equal #{c1[0].inspect} (but got #{c2.red.inspect})")
        assert_equal(c1[1], c2.green, "expected green to equal #{c1[1].inspect} (but got #{c2.green.inspect})")
        assert_equal(c1[2], c2.blue,  "expected blue to equal #{c1[2].inspect} (but got #{c2.blue.inspect})")
        assert_equal(c1[3], c2.alpha, "expected alpha to equal #{c1[3].inspect} (but got #{c2.alpha.inspect})")
      end

      # @param [Array<Integer>[4], Tone] c1
      # @param [Tone] c2
      def assert_equal_tone(t1, t2, msg = nil)
        t1 = [t1.red, t1.green, t1.blue, t1.gray] unless t1.is_a?(Array)
        assert_kind_of(Tone, t2)
        assert_equal(t1[0], t2.red,   "expected red to equal #{t1[0].inspect} (but got #{t2.red.inspect})")
        assert_equal(t1[1], t2.green, "expected green to equal #{t1[1].inspect} (but got #{t2.green.inspect})")
        assert_equal(t1[2], t2.blue,  "expected blue to equal #{t1[2].inspect} (but got #{t2.blue.inspect})")
        assert_equal(t1[3], t2.gray,  "expected gray to equal #{t1[3].inspect} (but got #{t2.gray.inspect})")
      end

      # @param [Array<Integer>[4], Rect]
      # @param [Rect]
      def assert_equal_rect(r1, r2, msg = nil)
        r1 = [r1.x, r1.y, r1.width, r1.height] unless r1.is_a?(Array)
        assert_kind_of(Rect, r2)
        assert_equal(r1[0], r2.x,      "expected x to equal #{r1[0].inspect} (but got #{r2.x.inspect})")
        assert_equal(r1[1], r2.y,      "expected y to equal #{r1[1].inspect} (but got #{r2.y.inspect})")
        assert_equal(r1[2], r2.width,  "expected width to equal #{r1[2].inspect} (but got #{r2.width.inspect})")
        assert_equal(r1[3], r2.height, "expected height to equal #{r1[3].inspect} (but got #{r2.height.inspect})")
      end
    end
  end
end

class RGSS3Spec
  class SpecSuite < Moon::Test::SpecSuite
    def initialize(name = nil)
      super name || default_name
      describe_top do |s|
        setup_specs s
      end
    end

    def auto_dispose(*objects)
      yield(*objects)
    ensure # always make sure this object gets disposed at the end of the block.
      objects.each do |object|
        begin
          object.dispose
        rescue => ex
          @log.error "Disposal of #{object.inspect} failed with #{ex.inspect}"
        end
      end
    end

    def default_name
      self.class.name
    end

    def setup_specs(s)
    end

    def run(*args)
      run_specs(*args)
    end
  end

  class SpecBuiltin < SpecSuite
    def default_name
      'Builtin'
    end

    def setup_specs(s)
      if '2.0.0' <= RUBY_VERSION
        # if you're running a 2.0.x RGSS
        s.it 'should have Fiddle' do
          assert_const_defined(:Fiddle)
        end
      elsif '1.9.2' <= RUBY_VERSION
        # if you're running a 1.9.x RGSS
        s.it 'should have DL' do
          assert_const_defined(:DL)
        end
      else
        # are you running 1.8 !?
        s.log.warn 'You seem to be running some old ruby...'
      end

      # regardless of platform
      s.it 'should have Zlib' do
        assert_const_defined(:Zlib)
      end

      if RUBY_PLATFORM =~ /(mswin|msvcrt|cygwin)/i
        # if this is a Windows implementation
        s.it 'should have Win32API' do
          assert_const_defined(:Win32API)
        end
      else
        s.log.note "You appear be using a none Windows implementation. (#{RUBY_PLATFORM})"
      end

      s.log.note "RUBY_PLATFORM #{RUBY_PLATFORM}"
      s.log.note "RUBY_VERSION #{RUBY_VERSION}"
      s.log.note "RUBY_ENGINE #{RUBY_ENGINE}"
    end
  end

  class SpecBuiltinFunctions < SpecSuite
    def default_name
      'Builtin-Functions'
    end

    def setup_specs(s)
      s.describe 'main_object' do
        s.it 'should define rgss_main and executes block' do
          assert_ary_include(:rgss_main, main_object.private_methods,
                            'expected rgss_main to be a private method in main object')
          executed = false
          rgss_main do
            executed = true
          end
          assert_true(executed, 'expected rgss_main block to execute')
        end

        s.it 'should define rgss_stop' do
          assert_ary_include(:rgss_stop, main_object.private_methods,
                             'expected rgss_stop to be a private method in main object')
          # There is no way in hell am I executing rgss_stop during the test.
          #Kernel.rgss_stop
        end
      end

      s.describe Kernel do
        s.context '#save_data' do
          s.it 'should be defined' do
            assert_respond_to(:save_data, Kernel)
          end
          s.it 'should dump a ruby object' do
            my_object = ['I <3', 'RUBY', RUBY_VERSION]
            Kernel.save_data(my_object, 'save_data_test.rdata')
            true
          end
        end

        s.context '#load_data' do
          s.it 'should be defined' do
            assert_respond_to(:load_data, Kernel)
          end

          s.it 'should load a dumped ruby object' do
            my_object = Kernel.load_data('save_data_test.rdata')
            assert_kind_of(Array, my_object)
            assert_equal(['I <3', 'RUBY', RUBY_VERSION], my_object)
          end
        end

        s.context '#msgbox' do
          s.it 'should be defined' do
            assert_respond_to(:msgbox, Kernel)
          end

          s.it 'should print a message' do
            Kernel.msgbox('Hello, World!')
            true
          end
        end

        s.context '#msgbox_p' do
          s.it 'should be defined' do
            assert_respond_to(:msgbox_p, Kernel)
          end

          s.it 'should print a object (using its #inspect)' do
            obj = Object.new
            def obj.inspect
              [:a, :b, 'Hello', 1, 2, 3].inspect
            end
            Kernel.msgbox_p(obj)
            true
          end
        end
      end
    end
  end

  class SpecBuiltinClasses < SpecSuite
    def default_name
      'Builtin-Classes'
    end

    def setup_bitmap_specs(s)
      s.describe 'Bitmap' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Bitmap)
          assert_kind_of(Class, Bitmap)
        end

        s.context '.new' do
          s.context 'with filename' do
            s.it 'should take a filename as a parameter' do
              bmp = Bitmap.new('Assets/test.png')
              bmp.dispose
            end

            s.it 'should raise a Errno::ENOENT if the file could not be found' do
              assert_raise Errno::ENOENT do
                bmp = Bitmap.new('Assets/some_image_that_shouldnt_exist.png')
                bmp.dispose
              end
            end
          end

          s.context 'with width and height' do
            s.it 'should take a width and height as a paremter' do
              auto_dispose(Bitmap.new(32, 24)) do |o|
                assert_equal(32, o.width)
                assert_equal(24, o.height)
              end
            end

            s.it 'should raise a RGSSError if the width or height is 0 or less' do
              assert_raise RGSSError do
                bmp = Bitmap.new(0, -1)
              end
            end

            s.it 'should create a bitmap as small as 1x1' do
              auto_dispose(Bitmap.new(1, 1)) do |o|
                assert_equal(1, o.width)
                assert_equal(1, o.height)
              end
            end

            # even Eb! RGSS3 FAILS THIS
            #s.it 'should create a bitmap as large as a uint16 (16 bits)' do
            #  f = 0xFFFF
            #  auto_dispose(Bitmap.new(f, f)) do |o|
            #    assert_equal(f, o.width)
            #    assert_equal(f, o.height)
            #  end
            #end
          end
        end # .new

        s.context '#width' do
          s.it 'should return the width of the Bitmap' do
            auto_dispose Bitmap.new(32, 32) do |bmp|
              assert_kind_of(Integer, bmp.width)
              assert_equal(32, bmp.width)
            end
          end
        end # #width

        s.context '#height' do
          s.it 'should return the height of the Bitmap' do
            auto_dispose Bitmap.new(32, 32) do |bmp|
              assert_kind_of(Integer, bmp.height)
              assert_equal(32, bmp.height)
            end
          end
        end # #height

        s.context '#dispose' do
          s.it 'should free the internal resource' do
            bmp = Bitmap.new(32, 32)
            bmp.dispose
            assert_disposed(bmp)
          end
        end # #dispose

        s.context '#rect' do
          s.it 'should return a Rect representing the size of the resource' do
            auto_dispose(Bitmap.new(32, 24)) do |o|
              r = o.rect
              assert_kind_of(Rect, r)
              assert_equal(0, r.x)
              assert_equal(0, r.y)
              assert_equal(32, r.width)
              assert_equal(24, r.height)
            end
          end
        end # #rect

        s.context '#blt' do
          s.it 'should blit a Bitmap unto another Bitmap' do
            auto_dispose(Bitmap.new(32, 24), Bitmap.new(16, 12)) do |b1, b2|
              b1.blt(0, 0, b2, b2.rect)
            end
          end

          s.it 'should blit a Bitmap unto another Bitmap (with optional alpha)' do
            auto_dispose(Bitmap.new(32, 24), Bitmap.new(16, 12)) do |b1, b2|
              b1.blt(0, 0, b2, b2.rect, 128)
            end
          end
        end # #blt

        s.context '#stretch_blt' do
          s.it 'should stretch blit a Bitmap unto another Bitmap' do
            auto_dispose(Bitmap.new(32, 24), Bitmap.new(16, 12)) do |b1, b2|
              b1.stretch_blt(b1.rect, b2, b2.rect)
            end
          end

          s.it 'should stretch blit a Bitmap unto another Bitmap (with optional alpha)' do
            auto_dispose(Bitmap.new(32, 24), Bitmap.new(16, 12)) do |b1, b2|
              b1.stretch_blt(b1.rect, b2, b2.rect, 128)
            end
          end
        end # #stretch_blt

        s.context '#fill_rect' do
          s.it 'should take an x, y, width and height' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.fill_rect(0, 0, 32, 24, Color.new(32, 32, 32, 255))
            end
          end

          s.it 'should take a rect' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.fill_rect(bmp.rect, Color.new(32, 32, 32, 255))
            end
          end

          s.it 'should raise an ArgumentError given insufficient arguments' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              assert_raise ArgumentError do
                bmp.fill_rect
              end

              assert_raise ArgumentError do
                bmp.fill_rect(Rect.new(0, 0, 32, 32))
              end

              assert_raise ArgumentError do
                bmp.fill_rect(0, 0, 32, 32)
              end
            end
          end
        end # #fill_rect

        s.context '#gradient_fill_rect' do
          s.it 'should take an x, y, width and height' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.gradient_fill_rect(bmp.rect, Color.new(32, 32, 32, 255), Color.new(64, 64, 64, 255))
            end
          end

          s.it 'should take an x, y, width and height (with vertical flag)' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.gradient_fill_rect(bmp.rect, Color.new(32, 32, 32, 255), Color.new(64, 64, 64, 255), true)
            end
          end

          s.it 'should take a rect' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.gradient_fill_rect(bmp.rect, Color.new(32, 32, 32, 255), Color.new(64, 64, 64, 255))
            end
          end

          s.it 'should take a rect (with vertical flag)' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.gradient_fill_rect(bmp.rect, Color.new(32, 32, 32, 255), Color.new(64, 64, 64, 255), true)
            end
          end

          s.it 'should raise an ArgumentError given insufficient arguments' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              assert_raise ArgumentError do
                bmp.gradient_fill_rect
              end

              assert_raise ArgumentError do
                bmp.gradient_fill_rect(Rect.new(0, 0, 32, 32))
              end

              assert_raise ArgumentError do
                bmp.gradient_fill_rect(0, 0, 32, 32)
              end
            end
          end
        end # #gradient_fill_rect

        s.context '#clear' do
          s.it 'should clear the resource' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.clear
            end
          end
        end # #clear

        s.context '#clear_rect' do
          s.it 'should clear a rect given a x, y, width and height' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.clear_rect(4, 4, 16, 12)
            end
          end

          s.it 'should clear a rect given a Rect' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.clear_rect(bmp.rect)
            end
          end
        end # #clear_rect

        s.context '#get_pixel' do
          s.it 'should get a pixel' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              r = bmp.get_pixel(4, 4)
              assert_kind_of(Color, r)
            end
          end

          s.it 'should return a blank pixel given an out of bound value' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              r = bmp.get_pixel(36, 4)
              assert_equal_color([0, 0, 0, 0], r)
            end
          end
        end # #get_pixel

        s.context '#set_pixel' do
          s.it 'should set a pixel' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.set_pixel(4, 4, Color.new(32, 32, 32, 255))
            end
          end

          s.it 'should set a pixel (ignoring out of bounds coords)' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              # I went to space!
              bmp.set_pixel(36, 4, Color.new(32, 32, 32, 255))
            end
          end
        end # #get_pixel

        s.context '#hue_change' do
          s.it 'should hue change the bitmap' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.hue_change(32)
            end
          end

          s.it 'should hue change the bitmap (wrapping value)' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.hue_change(378) # should be wrapped to 18
            end
          end
        end # #hue_change

        s.context '#blur' do
          s.it 'should blur the bitmap' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.blur
            end
          end
        end # #blur

        s.context '#radial_blur' do
          s.it 'should radial blur the bitmap' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              bmp.radial_blur(45, 6)
            end
          end

          s.it 'should raise an ArgumentError given insufficient arguments' do
            auto_dispose(Bitmap.new(32, 24)) do |bmp|
              assert_raise ArgumentError do
                bmp.radial_blur
              end

              assert_raise ArgumentError do
                bmp.radial_blur(45)
              end
            end
          end
        end # #radial_blur

        s.context '#draw_text' do
          s.it 'should draw text to the bitmap' do
            auto_dispose(Bitmap.new(320, 240)) do |bmp|
              bmp.draw_text(0, 0, 320, 24, 'Well, how goes it!')
            end
          end

          s.it 'should draw text to the bitmap (with aligns)' do
            auto_dispose(Bitmap.new(320, 240)) do |bmp|
              bmp.draw_text(0, 0, 320, 24, 'Line no 1', 0)
              bmp.draw_text(0, 24, 320, 24, 'Line no 2', 1)
              bmp.draw_text(0, 48, 320, 24, 'Line no 3 ;3', 2)
            end
          end

          s.it 'should draw text to the bitmap (given a Rect)' do
            auto_dispose(Bitmap.new(320, 240)) do |bmp|
              bmp.draw_text(Rect.new(0, 0, 320, 24), 'Well, how goes it!')
            end
          end

          s.it 'should draw text to the bitmap (with aligns)' do
            auto_dispose(Bitmap.new(320, 240)) do |bmp|
              bmp.draw_text(Rect.new(0, 0, 320, 24), 'Line no 1', 0)
              bmp.draw_text(Rect.new(0, 24, 320, 24), 'Line no 2', 1)
              bmp.draw_text(Rect.new(0, 48, 320, 24), 'Line no 3 ;3', 2)
            end
          end
        end # #draw_text

        s.context '#text_size' do
          s.it 'should return a Rect representing the text size' do
            auto_dispose Bitmap.new(320, 240) do |bmp|
              r = bmp.text_size('Hello, World')
              assert_kind_of(Rect, r)
            end
          end
        end # #text_size

        s.context 'Properties' do
          s.it 'should have a font' do
            auto_dispose Bitmap.new(320, 240) do |bmp|
              assert_kind_of(Font, bmp.font)
              my_font = Font.new
              bmp.font = my_font
              assert_kind_of(Font, bmp.font)
              # down right, we'd love if they where equal.
              assert_same(my_font, bmp.font)
            end
          end
        end
      end # Bitmap
    end

    def setup_color_specs(s)
      s.describe 'Color' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Color)
          assert_kind_of(Class, Color)
        end

        s.context '.new' do
          s.it 'should create a Color from no parameters' do
            r = Color.new
            assert_equal_color([0, 0, 0, 0], r)
          end

          s.it 'should create a Color from a Color' do
            c = Color.new(32, 15, 0, 198)
            r = Color.new(c)
            assert_equal_color(c, r)
          end

          s.it 'should create a Color from 3 parameters (alpha should be assumed as 255)' do
            r = Color.new(128, 96, 46)
            assert_equal_color([128, 96, 46, 255], r)
          end

          s.it 'should create a Color from 4 parameters' do
            r = Color.new(128, 96, 46, 196)
            assert_equal_color([128, 96, 46, 196], r)
          end
        end # .new

        s.context '#set' do
          s.it 'should set a color from 3 parameters' do
            r = Color.new
            r.set(128, 96, 32)
            assert_equal_color([128, 96, 32, 255], r)
          end

          s.it 'should set a color from 4 parameters' do
            r = Color.new
            r.set(128, 96, 32, 196)
            assert_equal_color([128, 96, 32, 196], r)
          end

          s.context 'should raise an ArgumentError' do
            s.given 'no parameters' do
              assert_raise ArgumentError do
                r = Color.new
                r.set
              end
            end

            s.given '2 parameters' do
              assert_raise ArgumentError do
                r = Color.new
                r.set(255, 129)
              end
            end

            s.given 'too many parameters' do
              assert_raise ArgumentError do
                r = Color.new
                r.set(255, 129, 255, 98, 127, 12)
              end
            end
          end
        end # #set

        s.context 'Properties' do
          s.context '#red' do
            s.it 'should have the red property' do
              r = Color.new(128, 1, 2, 255)
              assert_equal_color([128, 1, 2, 255], r)
              r.red = 96
              # ensure that only the red property changed
              assert_equal_color([96, 1, 2, 255], r)
            end
          end # #red

          s.context '#green' do
            s.it 'should have the green property' do
              r = Color.new(128, 1, 2, 255)
              assert_equal_color([128, 1, 2, 255], r)
              r.green = 96
              # ensure that only the green property changed
              assert_equal_color([128, 96, 2, 255], r)
            end
          end # #green

          s.context '#blue' do
            s.it 'should have the blue property' do
              r = Color.new(128, 1, 2, 255)
              assert_equal_color([128, 1, 2, 255], r)
              r.blue = 96
              # ensure that only the blue property changed
              assert_equal_color([128, 1, 96, 255], r)
            end
          end # #blue

          s.context '#alpha' do
            s.it 'should have the alpha property' do
              r = Color.new(128, 1, 2, 255)
              assert_equal_color([128, 1, 2, 255], r)
              r.alpha = 96
              # ensure that only the alpha property changed
              assert_equal_color([128, 1, 2, 96], r)
            end
          end # #alpha
        end # Properties
      end
    end

    def setup_font_specs(s)
      s.describe 'Font' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Font)
          assert_kind_of(Class, Font)
        end

        s.context '.new' do
          s.it 'should create a Font given a name' do
            # most systems SHOULD have Arial... otherwise, the hell kind of system
            # are you running!?
            font = Font.new('Arial')
          end
        end # .new

        s.context '.exist?' do
          s.it 'should return whether or not a font exists' do
            assert_true(Font.exist?('Arial'))
            # the hell kind of font is the The Great Bread Man anyway?
            assert_false(Font.exist?('The Great Bread Man'))
          end
        end # .exist?

        s.context 'Properties' do
          s.context '#name' do
            s.it 'should have a name' do
              f = Font.new
              assert_equal(Font.default_name, f.name)
              assert_kind_of_any([String, Array], f.name)
              f.name = ['Arial', 'Verdana', 'VL Gothic']
              assert_equal(['Arial', 'Verdana', 'VL Gothic'], f.name)
            end
          end # #name

          s.context '#size' do
            s.it 'should have a size' do
              f = Font.new
              assert_equal(Font.default_size, f.size)
              assert_kind_of(Integer, f.size)
              f.size = 16
              assert_equal(16, f.size)
            end
          end # #size

          s.context '#bold' do
            s.it 'should have a bold' do
              f = Font.new
              assert_equal(Font.default_bold, f.bold)
              assert_kind_of(Boolean, f.bold)
              f.bold = true
              assert_true(f.bold)
              f.bold = false
              assert_false(f.bold)
            end
          end # #bold

          s.context '#italic' do
            s.it 'should have a italic' do
              f = Font.new
              assert_equal(Font.default_italic, f.italic)
              assert_kind_of(Boolean, f.italic)
              f.italic = true
              assert_true(f.italic)
              f.italic = false
              assert_false(f.italic)
            end
          end # #italic

          s.context '#outline' do
            s.it 'should have a outline' do
              f = Font.new
              assert_equal(Font.default_outline, f.outline)
              assert_kind_of(Boolean, f.outline)
              f.outline = true
              assert_true(f.outline)
              f.outline = false
              assert_false(f.outline)
            end
          end # #outline

          s.context '#shadow' do
            s.it 'should have a shadow' do
              f = Font.new
              assert_equal(Font.default_shadow, f.shadow)
              assert_kind_of(Boolean, f.shadow)
              f.shadow = true
              assert_true(f.shadow)
              f.shadow = false
              assert_false(f.shadow)
            end
          end # #shadow

          s.context '#color' do
            s.it 'should have a color' do
              f = Font.new
              assert_equal_color(Font.default_color, f.color)
              assert_kind_of(Color, f.color)
              f.color = Color.new(32, 32, 32, 255)
              assert_equal_color([32, 32, 32, 255], f.color)
            end
          end # #color

          s.context '#out_color' do
            s.it 'should have a out_color' do
              f = Font.new
              assert_equal_color(Font.default_out_color, f.out_color)
              assert_kind_of(Color, f.out_color)
              f.out_color = Color.new(32, 32, 32, 255)
              assert_equal_color([32, 32, 32, 255], f.out_color)
            end
          end # #out_color
        end # Properties

        s.context 'class Properties' do
          s.context '.default_name' do
            s.it 'should have a default_name' do
              assert_kind_of_any([String, Array], Font.default_name)
              o = Font.default_name
              Font.default_name = ['Arial', 'Verdana', 'VL Gothic']
              assert_equal(['Arial', 'Verdana', 'VL Gothic'], Font.default_name)
              Font.default_name = o
            end
          end # .default_name

          s.context '.default_size' do
            s.it 'should have a default_size' do
              assert_kind_of(Integer, Font.default_size)
              Font.default_size = 16
              assert_equal(16, Font.default_size)
            end
          end # .default_size

          s.context '.default_bold' do
            s.it 'should have a default_bold' do
              assert_kind_of(Boolean, Font.default_bold)
              Font.default_bold = true
              assert_true(Font.default_bold)
              Font.default_bold = false
              assert_false(Font.default_bold)
            end
          end # .default_bold

          s.context '.default_italic' do
            s.it 'should have a default_italic' do
              assert_kind_of(Boolean, Font.default_italic)
              Font.default_italic = true
              assert_true(Font.default_italic)
              Font.default_italic = false
              assert_false(Font.default_italic)
            end
          end # .default_italic

          s.context '.default_outline' do
            s.it 'should have a default_outline' do
              assert_kind_of(Boolean, Font.default_outline)
              Font.default_outline = true
              assert_true(Font.default_outline)
              Font.default_outline = false
              assert_false(Font.default_outline)
            end
          end # .default_outline

          s.context '.default_shadow' do
            s.it 'should have a default_shadow' do
              assert_kind_of(Boolean, Font.default_shadow)
              Font.default_shadow = true
              assert_true(Font.default_shadow)
              Font.default_shadow = false
              assert_false(Font.default_shadow)
            end
          end # .default_shadow

          s.context '.default_color' do
            s.it 'should have a default_color' do
              assert_kind_of(Color, Font.default_color)
              Font.default_color = Color.new(32, 32, 32, 255)
              assert_equal_color([32, 32, 32, 255], Font.default_color)
            end
          end # .default_color

          s.context '.default_out_color' do
            s.it 'should have a out_color' do
              assert_kind_of(Color, Font.default_out_color)
              Font.default_out_color = Color.new(32, 32, 32, 255)
              assert_equal_color([32, 32, 32, 255], Font.default_out_color)
            end
          end # .default_out_color
        end # class Properties
      end
    end

    def setup_plane_specs(s)
      s.describe 'Plane' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Plane)
          assert_kind_of(Class, Plane)
        end

        s.context '.new' do
          it 'should create a Plane without a viewport' do
            auto_dispose(Plane.new) do |plane|
              assert_equal(nil, plane.viewport)
            end
          end

          it 'should create a Plane with a viewport' do
            v = Viewport.new
            auto_dispose(Plane.new(v), v) do |plane, viewport|
              assert_same(viewport, plane.viewport)
            end
          end
        end

        s.context '#dispose' do
          it 'should dispose the resource' do
            plane = Plane.new
            plane.dispose
            assert_disposed(plane)
          end
        end

        s.context 'Properties' do
          s.context '#bitmap' do
            it 'should have a bitmap' do
              auto_dispose(Plane.new, Bitmap.new(32, 32)) do |plane, bitmap|
                assert_equal(nil, plane.bitmap)
                plane.bitmap = bitmap
                assert_kind_of(Bitmap, plane.bitmap)
                assert_same(bitmap, plane.bitmap)
              end
            end
          end

          s.context '#viewport' do
            it 'should have a viewport' do
              auto_dispose(Plane.new, Viewport.new) do |plane, viewport|
                assert_equal(nil, plane.viewport)
                plane.viewport = viewport
                assert_kind_of(Viewport, plane.viewport)
                assert_same(viewport, plane.viewport)
              end
            end
          end

          s.context '#visible' do
            it 'should have a visible' do
              auto_dispose(Plane.new) do |plane|
                assert_equal_default(true, plane.visible)
                plane.visible = false
                assert_equal(false, plane.visible)
                plane.visible = true
                assert_equal(true, plane.visible)
              end
            end
          end

          s.context '#z' do
            it 'should have a z' do
              auto_dispose(Plane.new) do |plane|
                assert_kind_of(Integer, plane.z)
                assert_equal(0, plane.z)
                plane.z = 12
                assert_equal(12, plane.z)
              end
            end
          end

          s.context '#ox' do
            it 'should have a ox' do
              auto_dispose(Plane.new) do |plane|
                assert_kind_of(Integer, plane.ox)
                assert_equal(0, plane.ox)
                plane.ox = 12
                assert_equal(12, plane.ox)
              end
            end
          end

          s.context '#oy' do
            it 'should have a oy' do
              auto_dispose(Plane.new) do |plane|
                assert_kind_of(Integer, plane.oy)
                assert_equal(0, plane.oy)
                plane.oy = 12
                assert_equal(12, plane.oy)
              end
            end
          end

          s.context '#zoom_x' do
            it 'should have a zoom_x' do
              auto_dispose(Plane.new) do |plane|
                assert_kind_of(Float, plane.zoom_x)
                assert_float(1.0, plane.zoom_x)
                plane.zoom_x = 4
                assert_float(4.0, plane.zoom_x)
              end
            end
          end

          s.context '#zoom_y' do
            it 'should have a zoom_y' do
              auto_dispose(Plane.new) do |plane|
                assert_kind_of(Float, plane.zoom_y)
                assert_float(1.0, plane.zoom_y)
                plane.zoom_y = 3
                assert_float(3.0, plane.zoom_y)
              end
            end
          end

          s.context '#opacity' do
            it 'should have an opacity' do
              auto_dispose(Plane.new) do |plane|
                assert_equal(255, plane.opacity)
                plane.opacity = 12
                assert_equal(12, plane.opacity)
              end
            end

            it 'should have clamp opacity values' do
              auto_dispose(Plane.new) do |plane|
                assert_equal(255, plane.opacity)
                plane.opacity = 289
                assert_equal(255, plane.opacity)
                plane.opacity = -78
                assert_equal(0, plane.opacity)
              end
            end
          end

          s.context '#blend_type' do
            it 'should have a blend_type' do
              auto_dispose(Plane.new) do |plane|
                assert_equal(0, plane.blend_type)
                plane.blend_type = 1
                assert_equal(1, plane.blend_type)
              end
            end
          end

          s.context '#color' do
            it 'should have a color' do
              auto_dispose(Plane.new) do |plane|
                assert_kind_of(Color, plane.color)
                assert_equal_color([0, 0, 0, 0], plane.color)
                color = Color.new(32, 32, 32, 96)
                plane.color = color
                assert_kind_of(Color, plane.color)
                assert_equal_color([32, 32, 32, 96], plane.color)
                assert_same(color, plane.color)
              end
            end
          end

          s.context '#tone' do
            it 'should have a tone' do
              auto_dispose(Plane.new) do |plane|
                assert_kind_of(Tone, plane.tone)
                assert_equal_tone([0, 0, 0, 0], plane.tone)
                tone = Tone.new(32, -96, 3, 24)
                plane.tone = tone
                assert_kind_of(Tone, plane.tone)
                assert_equal_tone([32, -96, 3, 24], plane.tone)
                assert_same(tone, plane.tone)
              end
            end
          end
        end
      end
    end

    def setup_rect_specs(s)
      s.describe 'Rect' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Rect)
          assert_kind_of(Class, Rect)
        end

        s.context '.new' do
          s.it 'should create a Rect given no parameters' do
            rect = Rect.new
            assert_equal_rect([0, 0, 0, 0], rect)
          end

          # Enterbrain's RGSS3 will fail this.
          s.it 'should create a Rect given a Rect' do
            src_rect = Rect.new
            rect = Rect.new(src_rect)
            assert_equal_rect(src_rect, rect)
          end

          s.it 'should create a Rect given x, y, width and height' do
            rect = Rect.new(8, 4, 32, 24)
            assert_equal_rect([8, 4, 32, 24], rect)
          end
        end

        s.context 'Properties' do
          s.context '#x' do
            s.it 'should have a x property' do
              rect = Rect.new
              assert_kind_of(Integer, rect.x)
              assert_equal_rect([0, 0, 0, 0], rect)
              rect.x = 12
              assert_kind_of(Integer, rect.x)
              assert_equal_rect([12, 0, 0, 0], rect)
            end
          end

          s.context '#y' do
            s.it 'should have a y property' do
              rect = Rect.new
              assert_kind_of(Integer, rect.y)
              assert_equal_rect([0, 0, 0, 0], rect)
              rect.y = 12
              assert_kind_of(Integer, rect.y)
              assert_equal_rect([0, 12, 0, 0], rect)
            end
          end

          s.context '#width' do
            s.it 'should have a width property' do
              rect = Rect.new
              assert_kind_of(Integer, rect.width)
              assert_equal_rect([0, 0, 0, 0], rect)
              rect.width = 12
              assert_kind_of(Integer, rect.width)
              assert_equal_rect([0, 0, 12, 0], rect)
            end
          end

          s.context '#height' do
            s.it 'should have a height property' do
              rect = Rect.new
              assert_kind_of(Integer, rect.height)
              assert_equal_rect([0, 0, 0, 0], rect)
              rect.height = 12
              assert_kind_of(Integer, rect.height)
              assert_equal_rect([0, 0, 0, 12], rect)
            end
          end
        end
      end
    end

    def setup_sprite_specs(s)
      s.describe 'Sprite' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Sprite)
          assert_kind_of(Class, Sprite)
        end

        s.context '#initialize' do
          s.it 'should initialize without parameters' do
            auto_dispose(Sprite.new) do |s|
              assert_kind_of(Sprite, s)
            end
          end

          s.it 'should take a Viewport as an optional argument' do
            v = Viewport.new
            auto_dispose(Sprite.new(v), v) do |s, viewport|
              assert_kind_of(Sprite, s)
              assert_equal(viewport, s.viewport)
            end
          end
        end

        s.context '#dispose' do
          s.it 'should dispose the resource' do
            sprite = Sprite.new
            sprite.dispose
            assert_disposed(sprite)
          end
        end

        s.context '#flash' do
          s.it 'should flash a sprite given a color and duration' do
            auto_dispose(Sprite.new) do |s|
              c = Color.new(96, 0, 0, 196)
              d = 40
              s.flash(c, d)
            end
          end
        end

        s.context '#update' do
          s.it 'should update the sprite' do
            auto_dispose(Sprite.new) do |s|
              s.update
            end
          end
        end

        s.context '#width' do
          s.it 'should return the width of the sprite' do
            auto_dispose(Sprite.new) do |s|
              assert_equal_default(0, s.width)
              s.src_rect.set(0, 0, 32, 0)
              assert_equal(32, s.width)
            end
          end
        end

        s.context '#height' do
          s.it 'should return the height of the sprite' do
            auto_dispose(Sprite.new) do |s|
              assert_equal_default(0, s.height)
              s.src_rect.set(0, 0, 0, 32)
              assert_equal(32, s.height)
            end
          end
        end

        s.context 'Properties' do
          s.context '#bitmap' do
            it 'should have a bitmap' do
              auto_dispose(Sprite.new, Bitmap.new(32, 32)) do |sprite, bitmap|
                assert_equal_default(nil, sprite.bitmap)
                sprite.bitmap = bitmap
                assert_kind_of(Bitmap, sprite.bitmap)
                assert_same(bitmap, sprite.bitmap)
              end
            end
          end

          s.context '#src_rect' do
            it 'should have a src_rect' do
              auto_dispose(Sprite.new, Bitmap.new(32, 32)) do |sprite, bmp|
                assert_equal_rect([0, 0, 0, 0], sprite.src_rect, 'expected to default to empty Rect')
                sprite.bitmap = bmp
                assert_equal_rect([0, 0, 32, 32], sprite.src_rect)
                rect = Rect.new(0, 0, 24, 24)
                sprite.src_rect = rect
                assert_kind_of(Rect, sprite.src_rect)
                assert_same(rect, sprite.src_rect)
              end
            end
          end

          s.context '#viewport' do
            it 'should have a viewport' do
              auto_dispose(Sprite.new, Viewport.new) do |sprite, viewport|
                assert_equal_default(nil, sprite.viewport)
                sprite.viewport = viewport
                assert_kind_of(Viewport, sprite.viewport)
                assert_same(viewport, sprite.viewport)
              end
            end
          end

          s.context '#visible' do
            it 'should have a visible' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(true, sprite.visible)
                sprite.visible = false
                assert_equal(false, sprite.visible)
                sprite.visible = true
                assert_equal(true, sprite.visible)
              end
            end
          end

          s.context '#x' do
            it 'should have a x' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Integer, sprite.x)
                assert_equal_default(0, sprite.x)
                sprite.x = 12
                assert_equal(12, sprite.x)
              end
            end
          end

          s.context '#y' do
            it 'should have a y' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Integer, sprite.y)
                assert_equal_default(0, sprite.y)
                sprite.y = 12
                assert_equal(12, sprite.y)
              end
            end
          end

          s.context '#z' do
            it 'should have a z' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Integer, sprite.z)
                assert_equal_default(0, sprite.z)
                sprite.z = 12
                assert_equal(12, sprite.z)
              end
            end
          end

          s.context '#ox' do
            it 'should have a ox' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Integer, sprite.ox)
                assert_equal_default(0, sprite.ox)
                sprite.ox = 12
                assert_equal(12, sprite.ox)
              end
            end
          end

          s.context '#oy' do
            it 'should have a oy' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Integer, sprite.oy)
                assert_equal_default(0, sprite.oy)
                sprite.oy = 12
                assert_equal(12, sprite.oy)
              end
            end
          end

          s.context '#zoom_x' do
            it 'should have a zoom_x' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Float, sprite.zoom_x)
                assert_equal_default(1.0, sprite.zoom_x)
                sprite.zoom_x = 4
                assert_float(4.0, sprite.zoom_x)
              end
            end
          end

          s.context '#zoom_y' do
            it 'should have a zoom_y' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Float, sprite.zoom_y)
                assert_equal_default(1.0, sprite.zoom_y)
                sprite.zoom_y = 3
                assert_float(3.0, sprite.zoom_y)
              end
            end
          end

          s.context '#angle' do
            it 'should have an angle' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(0, sprite.angle)
                sprite.angle = 90
                assert_equal(90, sprite.angle)
                sprite.angle = 370
                assert_equal(370, sprite.angle)
              end
            end
          end

          s.context '#wave_amp' do
            it 'should have a wave_amp' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(0, sprite.wave_amp)
                sprite.wave_amp = 90
                assert_equal(90, sprite.wave_amp)
                sprite.wave_amp = 370
                assert_equal(370, sprite.wave_amp)
              end
            end
          end

          s.context '#wave_length' do
            it 'should have a wave_length' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(180, sprite.wave_length)
                sprite.wave_length = 90
                assert_equal(90, sprite.wave_length)
                sprite.wave_length = 370
                assert_equal(370, sprite.wave_length)
              end
            end
          end

          s.context '#wave_speed' do
            it 'should have a wave_speed' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(360, sprite.wave_speed)
                sprite.wave_speed = 90
                assert_equal(90, sprite.wave_speed)
                sprite.wave_speed = 370
                assert_equal(370, sprite.wave_speed)
              end
            end
          end

          s.context '#wave_phase' do
            it 'should have a wave_phase' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(0, sprite.wave_phase)
                sprite.wave_phase = 90
                assert_equal(90, sprite.wave_phase)
                sprite.wave_phase = 370
                assert_equal(10, sprite.wave_phase, 'expected 370 to be rounded to 10')
              end
            end
          end

          s.context '#mirror' do
            it 'should have a mirror' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(false, sprite.mirror)
                sprite.mirror = false
                assert_equal(false, sprite.mirror)
                sprite.mirror = true
                assert_equal(true, sprite.mirror)
              end
            end
          end

          s.context '#bush_depth' do
            it 'should have a bush_depth' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(0, sprite.bush_depth)
                sprite.bush_depth = 12
                assert_equal(12, sprite.bush_depth)
              end
            end
          end

          s.context '#bush_opacity' do
            it 'should have a bush_opacity' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal_default(0, sprite.bush_opacity)
                sprite.bush_opacity = 195
                assert_equal(195, sprite.bush_opacity)
                sprite.bush_opacity = -23
                assert_equal(0, sprite.bush_opacity, "expected value(#{sprite.bush_opacity}) to be clamped to 0")
                sprite.bush_opacity = 265
                assert_equal(255, sprite.bush_opacity, "expected value(#{sprite.bush_opacity}) to be clamped to 255")
              end
            end
          end

          s.context '#opacity' do
            it 'should have an opacity' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal(255, sprite.opacity)
                sprite.opacity = 12
                assert_equal(12, sprite.opacity)
                sprite.opacity = -78
                assert_equal(0, sprite.opacity, "expected value(#{sprite.opacity}) to be clamped to 0")
                sprite.opacity = 289
                assert_equal(255, sprite.opacity, "expected value(#{sprite.opacity}) to be clamped to 255")
              end
            end
          end

          s.context '#blend_type' do
            it 'should have a blend_type' do
              auto_dispose(Sprite.new) do |sprite|
                assert_equal(0, sprite.blend_type)
                sprite.blend_type = 1
                assert_equal(1, sprite.blend_type)
              end
            end
          end

          s.context '#color' do
            it 'should have a color' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Color, sprite.color)
                assert_equal_color([0, 0, 0, 0], sprite.color)
                color = Color.new(32, 32, 32, 96)
                sprite.color = color
                assert_kind_of(Color, sprite.color)
                assert_equal_color([32, 32, 32, 96], sprite.color)
                assert_same(color, sprite.color)
              end
            end
          end

          s.context '#tone' do
            it 'should have a tone' do
              auto_dispose(Sprite.new) do |sprite|
                assert_kind_of(Tone, sprite.tone)
                assert_equal_tone([0, 0, 0, 0], sprite.tone)
                tone = Tone.new(32, -96, 3, 24)
                sprite.tone = tone
                assert_kind_of(Tone, sprite.tone)
                assert_equal_tone([32, -96, 3, 24], sprite.tone)
                assert_same(tone, sprite.tone)
              end
            end
          end
        end
      end
    end

    def setup_table_specs(s)
      s.describe 'Table' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Table)
          assert_kind_of(Class, Table)
        end

        s.context '1D' do
          s.context '#initialize' do
            s.it 'should initialize given 1 dimension' do
              t = Table.new(24)
              assert_equal(24, t.xsize)
            end
          end

          s.context '#resize' do
            s.it 'should resize a table and preserve data' do
              t = Table.new(24)
              24.times { |i| t[i] = 23 - i }
              t.resize(32)
              assert_true(24.times.all? { |i| t[i] == (23 - i) })
              t.resize(16)
              assert_true(16.times.all? { |i| t[i] == (23 - i) })
            end
          end

          s.context '#[] and #[]=' do
            s.it 'should access a value at index' do
              t = Table.new(24)
              assert_equal(0, t[0])
              assert_equal(0, t[23])
              t[0] = 4
              assert_equal(4, t[0])
              t[23] = 8
              assert_equal(8, t[23])
            end

            s.it 'should fail when accessing dimensions not initialized with' do
              t = Table.new(24)
              assert_raise ArgumentError do
                t[0, 0]
              end

              assert_raise ArgumentError do
                t[0, 0, 0]
              end
            end
          end
        end # 1D

        s.context '2D' do
          s.context '#initialize' do
            s.it 'should initialize given 1 dimension' do
              t = Table.new(24, 16)
              assert_equal(24, t.xsize)
              assert_equal(16, t.ysize)
            end
          end

          s.context '#resize' do
            s.it 'should resize a table and preserve data' do
              t = Table.new(24, 16)
              16.times do |y|
                24.times do |x|
                  t[x, y] = x + y * 24
                end
              end
              t.resize(32, 24)
              assert_true(begin
                v = true
                16.times do |y|
                  24.times do |x|
                    v = t[x, y] == x + y * 24
                    break unless v
                  end
                end
                v
              end)
              t.resize(16, 8)
              assert_true(begin
                v = true
                8.times do |y|
                  16.times do |x|
                    v = t[x, y] == x + y * 24
                    break unless v
                  end
                end
                v
              end)
            end
          end

          s.context '#[] and #[]=' do
            s.it 'should access a value at index' do
              t = Table.new(24, 16)
              assert_equal(0, t[0, 0])
              assert_equal(0, t[23, 15])
              t[0, 0] = 4
              assert_equal(4, t[0, 0])
              t[23, 15] = 8
              assert_equal(8, t[23, 15])
            end
          end

          s.it 'should fail when accessing dimensions not initialized with' do
            t = Table.new(24, 16)
            assert_raise ArgumentError do
              t[0]
            end

            assert_raise ArgumentError do
              t[0, 0, 0]
            end
          end
        end # 2D

        s.context '3D' do
          s.context '#initialize' do
            s.it 'should initialize given 1 dimension' do
              t = Table.new(24, 16, 8)
              assert_equal(24, t.xsize)
              assert_equal(16, t.ysize)
              assert_equal(8, t.zsize)
            end
          end

          s.context '#resize' do
            s.it 'should resize a table and preserve data' do
              t = Table.new(24, 16, 8)
              8.times do |z|
                16.times do |y|
                  24.times do |x|
                    t[x, y, z] = x + y * 24 + z * 24 * 16
                  end
                end
              end
              t.resize(32, 24, 16)
              assert_true(begin
                v = true
                8.times do |z|
                  16.times do |y|
                    24.times do |x|
                      v = t[x, y, z] == x + y * 24 + z * 24 * 16
                      break unless v
                    end
                  end
                end
                v
              end)
              t.resize(16, 8, 4)
              assert_true(begin
                v = true
                4.times do |z|
                  8.times do |y|
                    16.times do |x|
                      v = t[x, y, z] == x + y * 24 + z * 24 * 16
                      break unless v
                    end
                  end
                end
                v
              end)
            end
          end

          s.context '#[] and #[]=' do
            s.it 'should access a value at index' do
              t = Table.new(24, 16, 8)
              assert_equal(0, t[0, 0, 0])
              assert_equal(0, t[23, 15, 7])
              t[0, 0, 0] = 4
              assert_equal(4, t[0, 0, 0])
              t[23, 15, 7] = 8
              assert_equal(8, t[23, 15, 7])
            end
          end

          s.it 'should fail when accessing dimensions not initialized with' do
            t = Table.new(24, 16, 8)
            assert_raise ArgumentError do
              t[0]
            end

            assert_raise ArgumentError do
              t[0, 0]
            end
          end
        end # 3D
      end
    end

    def setup_tilemap_specs(s)
      s.describe 'Tilemap' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Tilemap)
          assert_kind_of(Class, Tilemap)
        end
      end
    end

    def setup_tone_specs(s)
      s.describe 'Tone' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Tone)
          assert_kind_of(Class, Tone)
        end
      end
    end

    def setup_viewport_specs(s)
      s.describe 'Viewport' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Viewport)
          assert_kind_of(Class, Viewport)
        end
      end
    end

    def setup_window_specs(s)
      s.describe 'Window' do
        s.it 'should be defined as a class' do
          assert_const_defined(:Window)
          assert_kind_of(Class, Window)
        end
      end
    end

    def setup_rgss_error_specs(s)
      s.describe 'RGSSError' do
        s.it 'should be defined as a class' do
          assert_const_defined(:RGSSError)
          assert_kind_of(Class, RGSSError)
        end
      end
    end

    def setup_rgss_reset_specs(s)
      s.describe 'RGSSReset' do
        s.it 'should be defined as a class' do
          assert_const_defined(:RGSSReset)
          assert_kind_of(Class, RGSSReset)
        end
      end
    end

    def setup_specs(s)
      setup_bitmap_specs(s)
      setup_color_specs(s)
      setup_font_specs(s)
      setup_plane_specs(s)
      setup_rect_specs(s)
      setup_sprite_specs(s)
      setup_table_specs(s)
      setup_tilemap_specs(s)
      setup_tone_specs(s)
      setup_viewport_specs(s)
      setup_window_specs(s)
      setup_rgss_error_specs(s)
      setup_rgss_reset_specs(s)
    end
  end

  class SpecBuiltinModules < SpecSuite
    def default_name
      'Builtin-Modules'
    end

    def setup_audio_specs(s)
      s.describe 'Audio' do
        s.it 'should be defined as a module' do
          assert_const_defined(:Audio)
          assert_kind_of(Module, Audio)
        end
      end
    end

    def setup_graphics_specs(s)
      s.describe 'Graphics' do
        s.it 'should be defined as a module' do
          assert_const_defined(:Graphics)
          assert_kind_of(Module, Graphics)
        end
      end
    end

    def setup_input_specs(s)
      s.describe 'Input' do
        s.it 'should be defined as a module' do
          assert_const_defined(:Input)
          assert_kind_of(Module, Input)
        end
      end
    end

    def setup_specs(s)
      setup_audio_specs(s)
      setup_graphics_specs(s)
      setup_input_specs(s)
    end
  end

  def initialize
    @specs = []
    @specs << SpecBuiltin.new
    @specs << SpecBuiltinFunctions.new
    @specs << SpecBuiltinClasses.new
    @specs << SpecBuiltinModules.new
  end

  def remove_temp_files
    File.delete('save_data_test.rdata') if File.exist?('save_data_test.rdata')
  end

  def cleanup
    remove_temp_files
  end

  def prepare
    remove_temp_files
  end

  def run
    prepare
    stats = Moon::Test::SpecSuite::Stats.new
    @specs.each do |spec|
      stats.concat spec.run(quiet: true)
    end
    stats.display
    cleanup
  end
end
