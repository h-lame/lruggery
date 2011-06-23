require 'rubygems'
require 'hotcocoa'
require 'hotcocoa/graphics'

# Replace the following code with your own hotcocoa code
include HotCocoa
include Graphics

class SpeakerView < NSView
  ICON_SIZE = 73
  SHADOW_OFFSET = 4

  def speaker_icon_rect
    @speaker_icon_rect ||= NSMakeRect(0, 0, ICON_SIZE, ICON_SIZE)
  end

  def chosen_speaker_icon_rect
    @chosen_speaker_icon_rect ||= NSMakeRect(0, 0, ICON_SIZE * 2, ICON_SIZE * 2)
  end

  def speakers
    if @speakers.nil?
      @speakers = {}
      File.open(File.join(NSBundle.mainBundle.resourcePath.fileSystemRepresentation,'speakers.txt'),'r') do |list_of_twitter_names|
        list_of_twitter_names.lines.each do |line|
          twitter_name, real_name, talk_title = line.split(':',3).map(&:strip)
          twitter_name.gsub!(/^@/,'')
          @speakers[twitter_name] = {:real_name => real_name,
                                     :talk_title => talk_title,
                                     :image => Image.new(NSBundle.mainBundle.pathForResource(twitter_name, ofType:"png")),
                                     :used => false}
        end
      end
    end
    @speakers
  end

  def speaker_positions(for_rect)
    if @speaker_positions.nil?
      @speaker_positions = []
      speaker_names = speakers.keys
      padding_x = (for_rect.size.width % ICON_SIZE) / 2
      padding_y = (for_rect.size.height % ICON_SIZE) / 2
      (for_rect.size.width / ICON_SIZE).to_i.times do |row|
        (for_rect.size.height / ICON_SIZE).to_i.times do |col|
          speaker_names = speakers.keys if speaker_names.empty?
          speaker = speaker_names.delete_at(rand(speaker_names.length))
          draw_point = NSMakePoint((padding_x + (row * ICON_SIZE)), (padding_y + (col * ICON_SIZE)))
          @speaker_positions << {:speaker => speaker, :point => draw_point}
        end
      end
    end
    @speaker_positions
  end

  attr_reader :draw_mode
  attr_accessor :the_chosen_one

  def draw_mode=(new_draw_mode)
    @draw_mode = new_draw_mode
    setNeedsDisplay(true)
  end

  def drawRect(rect)
    graphics_context = NSGraphicsContext.currentContext
    graphics_context.saveGraphicsState

    case draw_mode
    when :speakers
      render_speakers(rect, graphics_context)
    when :chosen
      render_chosen(rect, graphics_context)
    end

    graphics_context.restoreGraphicsState
  end

  ENTER_KEY_CODE = 13

  def render_speakers(rect, graphics_context)
    NSLog "Rendering in speaker mode"
    NSColor.clearColor.set
    NSRectFill(bounds)

    core_image_context = graphics_context.CIContext

    speaker_positions(rect).each do |speaker_position|
      image = speakers[speaker_position[:speaker]][:image]
      core_image_context.drawImage image.ciimage, atPoint:speaker_position[:point], fromRect:speaker_icon_rect
    end
  end

  def determine_width_and_height_for_text_given_width(text, width, using_attributes)
    text_storage = NSTextStorage.alloc.initWithString text
    text_container = NSTextContainer.alloc.initWithContainerSize NSMakeSize(width, 10_000)
    layout_manager = NSLayoutManager.alloc.init

    layout_manager.addTextContainer(text_container)

    text_storage.addLayoutManager(layout_manager)

    range = NSMakeRange(0, text_storage.length)
    using_attributes.each do |key, value|
      text_storage.addAttribute(key, value:value, range:range)
    end

    text_container.setLineFragmentPadding(0.0)

    layout_manager.glyphRangeForTextContainer(text_container)

    [layout_manager.usedRectForTextContainer(text_container).size.width, layout_manager.usedRectForTextContainer(text_container).size.height]
  end

  def render_chosen(rect, graphics_context)
    NSLog "Rendering in chosen mode"
    NSColor.whiteColor.set
    NSRectFill(bounds)

    core_image_context = graphics_context.CIContext

    x_icon = (rect.size.width / 2) - ICON_SIZE
    y_icon = (rect.size.height / 2) - ICON_SIZE

    core_image_context.drawImage self.the_chosen_one[:image].ciimage, atPoint:[x_icon.to_i, y_icon.to_i], fromRect:chosen_speaker_icon_rect

    draw_text_banner(self.the_chosen_one[:real_name], rect, :below)

    draw_text_banner(self.the_chosen_one[:talk_title], rect, :above)
  end

  def rect_with_shadow_offset(x, y, w, h)
    return [x, 
            y, 
            w+SHADOW_OFFSET, 
            h+SHADOW_OFFSET]
  end

  def draw_text_banner(text, rect, above_or_below)
    max_width = rect.size.width - (rect.size.width * 0.024).to_i
    
    width_of_text, height_of_text = determine_width_and_height_for_text_given_width(text, max_width, text_attributes)

    x_text = (rect.size.width - width_of_text) / 2
    if above_or_below == :below
      y_text = (rect.size.height / 2) - 80 - height_of_text
    else
      y_text = (rect.size.height / 2) + 80
    end
    x_text = x_text.to_i
    y_text = y_text.to_i

    text_rect = rect_with_shadow_offset(x_text, y_text, width_of_text, height_of_text)

    text.drawInRect(text_rect, withAttributes: text_attributes)
  end

  def text_attributes
    if @text_attributes.nil?
      shadow = NSShadow.alloc.init
      shadow.shadowOffset = [SHADOW_OFFSET, -SHADOW_OFFSET]
      font = NSFont.fontWithName("Helvetica", size:60)
      paragraph = NSParagraphStyle.defaultParagraphStyle.mutableCopy
      paragraph.setAlignment(NSCenterTextAlignment)
      @text_attributes = {NSShadowAttributeName => shadow,
                          NSFontAttributeName => font,
                          NSForegroundColorAttributeName => NSColor.blackColor,
                          NSParagraphStyleAttributeName => paragraph}
    end
    @text_attributes
  end

  def acceptsFirstResponder
    true
  end

  def keyDown(event)
    characters = event.characters
    if characters.length == 1 && !event.isARepeat
      character = characters.characterAtIndex(0)
      if character == ENTER_KEY_CODE
        NSLog self.draw_mode.to_s
        case self.draw_mode
        when :speakers
          self.the_chosen_one = pick_a_speaker
          unless self.the_chosen_one.nil?
            self.the_chosen_one[:image] = self.the_chosen_one[:image].scale(2.0)
            self.draw_mode = :chosen
          end
        when :chosen
          update_chosen_speaker
          self.the_chosen_one = nil
          self.draw_mode = :speakers
        end
      end
    end
  end

  def update_chosen_speaker
    return if self.the_chosen_one.nil?
    self.the_chosen_one[:used] = true
    self.the_chosen_one[:image].reset
    self.the_chosen_one[:image] = self.the_chosen_one[:image].brightness(0.5)
    self.the_chosen_one[:image] = self.the_chosen_one[:image].blur(3.0)
  end

  def pick_a_speaker
    speaker_names = speakers.keys
    unused = speaker_names.select { |s| !speakers[s][:used] }
    unless unused.empty?
      chosen = unused[rand(unused.length)]
      NSLog "Selecting #{chosen}"
      speakers[chosen]
    end
  end
end

application :name => 'Speaker Selection' do |app|
  window(:size => [1024, 700],
         :center => true,
         :title => "Speaker Selection",
         :view => :nolayout,
         :style => [:titled, :closable]) do |win|
    win.contentView = SpeakerView.alloc.initWithFrame(win.frame)
    win.contentView.draw_mode = :speakers
    win.will_close { exit }
  end
end

