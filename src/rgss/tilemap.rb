
if $RGSS_VERSION == 2
  require 'rgss/tilemap_rgss2'
elsif $RGSS_VERSION == 3
  require 'rgss/tilemap_rgss3'
else

#==============================================================================
# ** Tilemap (hidden class)
#------------------------------------------------------------------------------
#  This class handles the map data to screen processing
#==============================================================================

#==============================================================================
#
#   Yet another Tilemap Script (for any map size /w autotiles)
#   by MeÃ¢ €žÂ¢ / Derk-Jan Karrenbeld (me@solarsoft.nl)
#   version 1.0 released on 08 nov 08
#   version 1.2
#
#==============================================================================
class Tilemap < RGSS::Tilemap
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader :tileset
  attr_accessor :autotiles
  attr_reader :flash_data
  attr_reader :priorities
  attr_reader :visible
  attr_reader :ox, :oy
  attr_reader :viewport
  attr_accessor :bitmaps # RGSS_VERSION == 2
  attr_accessor :passages # RGSS_VERSION == 2

  #--------------------------------------------------------------------------
  # * Constant Configuration
  #--------------------------------------------------------------------------

  # Window Rect - the visible Area of the Map (default: 640 x 480)
  # Bitmap Rect - the active drawing Area of the Map (window tiles + 2 tiles)
  # BitmapWindow offset - the invisible tile count on one side
  WindowRect = Rect.new(0,0,640,480)
  BitmapRect = Rect.new(0,0,640 + 64, 480 + 64) # Recommended
  BitmapWindowOffset = (BitmapRect.height-WindowRect.height)/2/32

  # Length in frames of one frame showing from autotile
  AutotileLength = 10

  # KillOutScreenSprite - Kills priority and autotile sprites out of screen
  # EnableFlashingData - If activated, enables updating flashing data
  KillOutScreenSprite   = true
  EnableFlashingData    = true

  # SingleFlashingSprite - Uses one Flashing sprite, instead of many
  # SinglePrioritySprite - Uses one Priority sprite, instead of many
  # SingleAutotileSprite - Uses one Autotile sprite, instead of many
  SingleFlashingSprite  = false
  SinglePrioritySprite  = false
  SingleAutotileSprite  = false

  # This is the Autotile animation graphical index array. It contains numbers
  # that point to the graphic part of an animating autotile.
  Autotiles = [
      [ [27, 28, 33, 34], [ 5, 28, 33, 34], [27,  6, 33, 34], [ 5,  6, 33, 34],
        [27, 28, 33, 12], [ 5, 28, 33, 12], [27,  6, 33, 12], [ 5,  6, 33, 12] ],
      [ [27, 28, 11, 34], [ 5, 28, 11, 34], [27,  6, 11, 34], [ 5,  6, 11, 34],
        [27, 28, 11, 12], [ 5, 28, 11, 12], [27,  6, 11, 12], [ 5,  6, 11, 12] ],
      [ [25, 26, 31, 32], [25,  6, 31, 32], [25, 26, 31, 12], [25,  6, 31, 12],
        [15, 16, 21, 22], [15, 16, 21, 12], [15, 16, 11, 22], [15, 16, 11, 12] ],
      [ [29, 30, 35, 36], [29, 30, 11, 36], [ 5, 30, 35, 36], [ 5, 30, 11, 36],
        [39, 40, 45, 46], [ 5, 40, 45, 46], [39,  6, 45, 46], [ 5,  6, 45, 46] ],
      [ [25, 30, 31, 36], [15, 16, 45, 46], [13, 14, 19, 20], [13, 14, 19, 12],
        [17, 18, 23, 24], [17, 18, 11, 24], [41, 42, 47, 48], [ 5, 42, 47, 48] ],
      [ [37, 38, 43, 44], [37,  6, 43, 44], [13, 18, 19, 24], [13, 14, 43, 44],
        [37, 42, 43, 48], [17, 18, 47, 48], [13, 18, 43, 48], [ 1,  2,  7,  8] ]
  ]

  #--------------------------------------------------------------------------
  # * Object Initialization
  #     viewport : the drawing viewport
  #     rpgmap : the rpgmap object
  #--------------------------------------------------------------------------
  def initialize(viewport = nil, rpgmap = nil)

    @autotiles    = Array.new(6, nil)
    @oldautotiles = Array.new(6, nil)
    # Tilemap Viewport
    @viewport   = viewport ? viewport : Viewport.new(WindowRect)
    # Showing Region Rectangle
    #@region     = Rect.new(0,0,BitmapRect.width/32, BitmapRect.height/32)
    # Old Region Rect
    #@oldregion  = nil
    # Set TilemapSprite
    #@sprite     = Sprite.new(@viewport)
    #@sprite.z = 32

    # Set Bitmap on Sprite
    #@sprite.bitmap = Bitmap.new(BitmapRect.width, BitmapRect.height)

    # Set FlashingSprite and bitmap
    if SingleFlashingSprite
      @flashsprite = Sprite.new(@viewport)
      @flashsprite.bitmap = Bitmap.new(BitmapRect.width, BitmapRect.height)
    end
    # Set Informational Arrays/Hashes
    @priority_ids     = {}  # Priority ids
    #@normal_tiles     = {}  # Non-auto tile bitmaps
    #@auto_tiles       = {}  # Autotile bitmaps
    #@priority_sprites = []  # Priority Sprites
    #@autotile_sprites = []  # Autotile Sprites
    @flashing_sprites = []  # Flashing Sprites
    # Disposal Boolean
    @disposed   = false
    # Visibility Boolean
    @visible    = true
    # Flashing Boolean
    @flashing   = true
    # Disable Drawing Boolean
    @can_draw   = true

    @redraw = false
    # Set Coords
    #@ox, @oy = 0, 0
    # Create TileMap if rpgmap is provided

    # RGSS_VERSION == 2
    @bitmaps = [nil] * 9
    @passages = nil

    create_tilemap(rpgmap) if !rpgmap.nil?

    Graphics.tilemap = self
  end
  #--------------------------------------------------------------------------
  # * Get Bitmap Sprite
  #--------------------------------------------------------------------------
  #def sprite_bitmap
  #  return @sprite.bitmap
  #end
  #--------------------------------------------------------------------------
  # * Data Tileset Referer - loads if needed
  #--------------------------------------------------------------------------
  def data_tilesets
    $data_tilesets ||= load_data("Data/Tilesets.rxdata")
  end
  #--------------------------------------------------------------------------
  # * Check: Disposed?
  #--------------------------------------------------------------------------
  def disposed?
    @disposed
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super

    # Dispose all sprites (and cached bitmaps for quick memory clearing)
    #for sprite in  @normal_tiles.values + @auto_tiles.values + @priority_sprites + @autotile_sprites + (SingleFlashingSprite ? [@flashsprite] : @flashing_sprites)
    #  sprite = sprite[0] if sprite.is_a?(Array)
    #  sprite.dispose if sprite.is_a?(Bitmap)
    #
    #  if sprite.is_a?(Sprite)
    #    sprite.bitmap.dispose if sprite.bitmap
    #    sprite.dispose
    #  end
    #end
    for sprite in (SingleFlashingSprite ? [@flashsprite] : @flashing_sprites)
      sprite = sprite[0] if sprite.is_a?(Array)
      sprite.dispose if sprite.is_a?(Bitmap)

      if sprite.is_a?(Sprite)
        sprite.bitmap.dispose if sprite.bitmap
        sprite.dispose
      end
    end
    # Set Informational Arrays/Hashes
    #@priority_ids     = {}  # Priority ids
    #@normal_tiles     = {}  # Non-auto tile bitmaps
    #@priority_sprites = []  # Priority Sprites
    #@autotile_sprites = []  # Autotile Sprites
    @flashing_sprites = []  # Flashing Sprites

    @tileset.dispose if @tileset

    @autotiles.each { |a| a.dispose if a }
    @flashsprite.dispose if @flashsprite

    # I am disposed
    @disposed = true
    Graphics.tilemap = nil
  end
  #--------------------------------------------------------------------------
  # * Check: Flashing
  #--------------------------------------------------------------------------
  def flashing?
    EnableFlashingData and @flashing and @flashing_sprites.size
  end
  #--------------------------------------------------------------------------
  # * Check: Visible
  #--------------------------------------------------------------------------
  def visible?
    @visible
  end
  #--------------------------------------------------------------------------
  # * Check: Autotiles Changed
  #--------------------------------------------------------------------------
  def autotiles_changed?
    @oldautotiles != @autotiles
  end
  #--------------------------------------------------------------------------
  # * Set Visibility
  #     value: new value
  #--------------------------------------------------------------------------
  def visible=(value)
    # Set Visibility value
    @visible = value
    # Update all sprites
    #for sprite in @priority_sprites + @autotile_sprites + (SingleFlashingSprite ? [@flashsprite] : @flashing_sprites)
    #  sprite = sprite[0] if sprite.is_a?(Array)
    #  sprite.visible = value
    #end
    for sprite in (SingleFlashingSprite ? [@flashsprite] : @flashing_sprites)
      sprite = sprite[0] if sprite.is_a?(Array)
      sprite.visible = value
    end
  end
  #--------------------------------------------------------------------------
  # * Set Tileset
  #     value : new RPG::Tileset, String or Bitmap
  #--------------------------------------------------------------------------
  def tileset=(value)
    # Return on equal data
    return if @tileset == value

    # Set TilesetName
    value = value.tileset_name if value.is_a?(RPG::Tileset)
    # Cache Tileset
    @tileset = RPG::Cache.tileset(value) if value.is_a?(String)

    # Set Tileset
    @tileset = value if value.is_a?(Bitmap)

    super

    # Draw Tileset
    redraw_tileset if @can_draw
  end
  #--------------------------------------------------------------------------
  # * Set Priorities
  #     value : new value
  #--------------------------------------------------------------------------
  def priorities=(value)
    # Return on equal data
    return if @priorities == value
    # Set Priorities
    @priorities = value
    # Draw Tileset
    redraw_priorities if @can_draw
  end
  #--------------------------------------------------------------------------
  # * Set flash data
  #     coord[0] : x
  #     coord[1] : y
  #     value    : Color or Hex
  #--------------------------------------------------------------------------
  def flash_data=(*coord, &value)
    # Return on equal data
    return if @flash_data[coord[0],coord[1]] == value
    # Already Flashing this tile?
    flashing = !@flash_data[x,y].nil?
    # Set Flash Data
    @flash_data[x,y] = value

    #return if !EnableFlashingData
    ## Take action and remove/change/add flash
    #if value.nil?
    #  remove_flash(x,y)
    #elsif flashing
    #  change_flash(x,y,value)
    #else
    #  add_flash(x,y,value)
    #end

    @redraw = true
  end
  #--------------------------------------------------------------------------
  # * Map Data referer
  #--------------------------------------------------------------------------
  def map_data
    @map_data
  end
  #--------------------------------------------------------------------------
  # * Set Map Data
  #     value : new Table value
  #--------------------------------------------------------------------------
  def map_data=(value)
    # Return on equal data
    return if @map_data == value
    # Set New Map Data
    @map_data = value
    # Flash Data Table
    @flash_data = Table.new(@map_data.xsize, @map_data.ysize)
    # Redraw Current Region
    #draw_region if @can_draw and @priorities and @tileset
  end
  #--------------------------------------------------------------------------
  # * Get Map width (in tiles)
  #--------------------------------------------------------------------------
  def map_tile_width
    map_data.xsize
  end
  #--------------------------------------------------------------------------
  # * Get Map height (in tiles)
  #--------------------------------------------------------------------------
  def map_tile_height
    map_data.ysize
  end
  #--------------------------------------------------------------------------
  # * Create Tilemap
  #     rpgmap : base object
  #--------------------------------------------------------------------------
  def create_tilemap(rpgmap)
    # Return on invalid data
    return if rpgmap.is_a?(RPG::Map) == false
    # Restrict drawing
    @can_draw = false
    # Set Local Tileset Object (RPG::Tileset)
    _tileset = data_tilesets[rpgmap.tileset_id]
    # Return on invalid data
    return if _tileset.is_a?(RPG::Tileset) == false
    # Set Informational Arrays/Hashes
    @priority_ids     = {}  # Priority ids
    @normal_tiles     = {}  # Non-auto tile bitmaps
    @priority_sprites = []  # Priority Sprites
    @autotile_sprites = []  # Autotile Sprites
    @flashing_sprites = []  # Flashing Sprites
    # Set Tileset
    tileset = _tileset.tileset_name
    # Set AutoTiles
    (0..6).each { |i| autotiles[i] = _tileset.autotile_names[i] }
    # Set Priorities
    priorities = _tileset.priorities
    # Set Mapdata
    map_data = rpgmap.map_data
    # Reset drawing
    @can_draw = true
    # Reset disposed (need to reinit info variables)
    @disposed = false

    # Draw Region
    #draw_region
  end
  #--------------------------------------------------------------------------
  # * Get Tile id
  #     x : x tile coord
  #     y : y tile coord
  #     z : z layer coord
  #--------------------------------------------------------------------------
  def tile_id(x, y, z)
    return @map_data[x, y, z]
  end
  #--------------------------------------------------------------------------
  # * Get Priority
  #     args (1) : tile_id
  #     args (3) : x, y, z coord
  #--------------------------------------------------------------------------
  def priority(*args)
    return @priorities[args[0]] if args.size == 1
    return @priorities[tile_id(args[0], args[1], args[2])]
  end
  #--------------------------------------------------------------------------
  # * Redraw Tileset (on change)
  #--------------------------------------------------------------------------
  def redraw_tileset
    super
  end
  #--------------------------------------------------------------------------
  # * Redraw Priorities (on change)
  #--------------------------------------------------------------------------
  def redraw_priorities
    ## Dispose current tiles in screen
    #(@autotile_sprites + @priority_sprites).each { |sprite| sprite[0].dispose if !sprite[0].disposed? }
    ## Clear disposed graphics
    #@priority_sprites.clear; @autotile_sprites.clear

    super

    # Clear Priority id information
    @priority_ids.clear
    # Do a one time check for all priorities (can't do @tileset.priorities
    # because RPG::Tilemap is normally not passed trough, but if it were, you
    # can do the following - just uncomment this part and command the next for
    # loop:
    ## for tile_id in 0...@tileset.priorities.xsize
    ##  next if @tileset.priorities[tile_id] == 0
    ##  @priority_ids[tile_id] = @tileset.priorities[tile_id]
    ## end
    # But because we don't have that data, just iterate trough the map and
    # get seperate priority data for each tile, and save if there is one.
    for z in 0...3
      for y in 0...map_tile_height
        for x in 0...map_tile_width
          next if (id = tile_id(x, y, z)) == 0
          next if (p = priority(id)) == 0
          @priority_ids[id] = p
        end
      end
    end
    # Draw if allowed
    #draw_region if @can_draw and @priorities and @tileset
  end
  #--------------------------------------------------------------------------
  # * Redraw autotiles (on change)
  #--------------------------------------------------------------------------
  def redraw_autotiles
    super

    # Save changes aka don't call this method again
    @oldautotiles = @autotiles
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update

  end
  def draw
    # Redraw if needed
    #redraw_tileset if @redraw
    #@redraw = false

    # Redraw autotiles if changed
    redraw_autotiles if autotiles_changed?
    # Cancel updating if invisible
    return if not visible?
    # Flash Tiles
    #update_flashing if flashing?

    # Update autotiles
    update_autotiles if (Graphics.frame_count % AutotileLength) == 0
    # Draw Region
    draw_current_region

    RGSS::TileRenderer.draw
  end

end

end