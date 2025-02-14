require File.join(File.dirname(__FILE__), 'gilded_rose')

RSpec.describe GildedRose do
  def update_quality_for(item)
    GildedRose.new([item]).update_quality
  end

  def assert_quality_never_negative(item)
    item.quality = 0
    update_quality_for(item)
    expect(item.quality).to eq 0

    item.sell_in = -1
    update_quality_for(item)
    expect(item.quality).to eq 0
  end

  def assert_quality_never_exceeds_50(item)
    item.quality = 50
    update_quality_for(item)
    expect(item.quality).to eq 50

    if item.name == "Backstage passes to a TAFKAL80ETC concert"
      item.sell_in = 5
    else
      item.sell_in = -1
    end
    item.quality = 49
    update_quality_for(item)
    expect(item.quality).to eq 50
  end

  def assert_backstage_pass_quality(sell_in, initial_quality, expected_increase)
    item = Item.new("Backstage passes to a TAFKAL80ETC concert", sell_in, initial_quality)
    update_quality_for(item)
    expect(item.quality).to eq [initial_quality + expected_increase, 50].min
  end

  describe "#update_quality" do
    context "with normal items" do
      let(:item) { Item.new("Normal Item", 5, 10) }

      it "decreases quality and sell_in by 1 before sell date" do
        update_quality_for(item)
        expect(item.quality).to eq 9
        expect(item.sell_in).to eq 4
      end

      it "decreases quality twice as fast after sell date" do
        item.sell_in = 0
        update_quality_for(item)
        expect(item.quality).to eq 8
        expect(item.sell_in).to eq -1
      end

      it "follows quality floor rules" do
        assert_quality_never_negative(item)
      end
    end

    context "with Aged Brie" do
      let(:item) { Item.new("Aged Brie", 5, 10) }

      it "increases quality by 1 before sell date" do
        update_quality_for(item)
        expect(item.quality).to eq 11
      end

      it "increases quality by 2 after sell date" do
        item.sell_in = -1
        update_quality_for(item)
        expect(item.quality).to eq 12
      end

      it "follows quality ceiling rules" do
        assert_quality_never_exceeds_50(item)
      end
    end

    context "with Sulfuras" do
      let(:item) { Item.new("Sulfuras, Hand of Ragnaros", 5, 80) }

      it "never changes quality or sell_in" do
        initial_quality = item.quality
        initial_sell_in = item.sell_in
        update_quality_for(item)

        expect(item.quality).to eq initial_quality
        expect(item.sell_in).to eq initial_sell_in
      end

      it "maintains quality even after sell date" do
        item.sell_in = -1
        update_quality_for(item)
        expect(item.quality).to eq 80
      end
    end

    context "with Backstage passes" do
      it "follows quality increase rules based on sell_in" do
        test_cases = [
          { sell_in: 11, quality: 10, increase: 1 },
          { sell_in: 10, quality: 10, increase: 2 },
          { sell_in: 8, quality: 10, increase: 2 },
          { sell_in: 5, quality: 10, increase: 3 },
          { sell_in: 3, quality: 10, increase: 3 }
        ]

        test_cases.each do |test_case|
          assert_backstage_pass_quality(
            test_case[:sell_in],
            test_case[:quality],
            test_case[:increase]
          )
        end
      end

      it "drops quality to 0 after concert" do
        [0, -1].each do |sell_in|
          item = Item.new("Backstage passes to a TAFKAL80ETC concert", sell_in, 10)
          update_quality_for(item)
          expect(item.quality).to eq 0
        end
      end

      it "follows quality ceiling rules" do
        item = Item.new("Backstage passes to a TAFKAL80ETC concert", 5, 48)
        assert_quality_never_exceeds_50(item)
      end
    end
  end
end
