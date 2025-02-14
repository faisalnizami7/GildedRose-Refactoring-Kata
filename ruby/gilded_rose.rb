class GildedRose
  MAXIMUM_QUALITY = 50
  MINIMUM_QUALITY = 0
  BACKSTAGE_PASS = "Backstage passes to a TAFKAL80ETC concert"
  AGED_BRIE = "Aged Brie"
  SULFURAS = "Sulfuras, Hand of Ragnaros"

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      next if sulfuras?(item)

      update_sell_in(item)
      update_item_quality(item)
      enforce_quality_limits(item)
    end
  end

  private

  def update_item_quality(item)
    case
    when aged_brie?(item)
      update_aged_brie_quality(item)
    when backstage_pass?(item)
      update_backstage_pass_quality(item)
    else
      update_normal_item_quality(item)
    end
  end

  def update_aged_brie_quality(item)
    increase_quality(item)
    increase_quality(item) if expired?(item)
  end

  def update_backstage_pass_quality(item)
    if expired?(item)
      item.quality = MINIMUM_QUALITY
      return
    end

    if item.sell_in <= 4
      increase_quality(item)
      increase_quality(item)
      increase_quality(item)
    elsif item.sell_in <= 9
      increase_quality(item)
      increase_quality(item)
    else
      increase_quality(item)
    end
  end

  def update_normal_item_quality(item)
    decrease_quality(item)
    decrease_quality(item) if expired?(item)
  end

  def update_sell_in(item)
    item.sell_in -= 1
  end

  def increase_quality(item)
    item.quality += 1 if item.quality < MAXIMUM_QUALITY
  end

  def decrease_quality(item)
    item.quality -= 1 if item.quality > MINIMUM_QUALITY
  end

  def enforce_quality_limits(item)
    return if sulfuras?(item)
    item.quality = MAXIMUM_QUALITY if item.quality > MAXIMUM_QUALITY
    item.quality = MINIMUM_QUALITY if item.quality < MINIMUM_QUALITY
  end

  def expired?(item)
    item.sell_in < 0
  end

  def aged_brie?(item)
    item.name == AGED_BRIE
  end

  def sulfuras?(item)
    item.name == SULFURAS
  end

  def backstage_pass?(item)
    item.name == BACKSTAGE_PASS
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
