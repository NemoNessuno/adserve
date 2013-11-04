require_relative './categories_helper.rb'

module ApplicationHelper

  include CategoriesHelper
  include MessageHandler

  def empty_column 
    @empty_column ||= {
      :tag_name => [],
      :tag_proc => nil
    }
  end

  def inspect_id_column
    @inspect_id_column ||= {
      :tag_name => [:display_name => "Details"],
      :tag_proc => Proc.new { |id| link_to "Details",publishers_show_campaign_path(:id => id)}
    }
  end

  def choose_ad_column
    @chose_ad_column ||= {
      :tag_name => [:display_name => "Select"],
      :tag_proc => Proc.new { |id| check_box_tag("ad_#{id}")}
    }
  end

  def choose_ad_for_zone_column(zone_id)
    @chose_ad_column ||= {}
    @chose_ad_column[zone_id] ||= {
      :tag_name => [:display_name => "Select"],
      :tag_proc => Proc.new { |id| check_box_tag("zone_#{zone_id}_ad_#{id}")}
    }
  end

  def choose_zone_column
    @chose_ad_column ||= {
      :tag_name => [:display_name => "Select"],
      :tag_proc => Proc.new { |id| check_box_tag("zone_#{id}")}
    }
  end
  
  def no_options
    @no_options ||= {
      :class => "",
      :onclick => Proc.new {|id| " "}
    }
  end

  def zone_onclick_html
    @zone_onclick_html ||= ({
      :class => "clickable",
      :onclick => Proc.new {|id| "showAds('#{id}');"}
    })
  end

  def modelAccessor
    Proc.new {|model, category| model.send(category)}
  end

  def hashAccessor
    Proc.new {|hash, category| hash[category]}
  end

  def standard_table(columns, collection, id = nil, acc = modelAccessor, extra_column = empty_column, html_options = no_options)

    thead = content_tag :thead do
      content_tag :tr do
        columns.dup.concat(extra_column[:tag_name]).collect {|column| concat content_tag(:th,column[:display_name])}.join().html_safe
      end
    end
    
    i = 0
     
    tbody = content_tag :tbody do
      collection.collect { |elem|
        content_tag(:tr, 
                    :class => "#{html_options[:class]} #{((i += 1) % 2) == 0 ? "even" : "odd"}",
                    :onclick => html_options[:onclick].call(acc.call(elem, :id)))do
          column_content = columns.collect { |column|
            content_tag(:td, acc.call(elem, column[:name].to_sym))
          }.join().to_s.html_safe
          unless (extra_column[:tag_proc].nil?)
            column_content += (content_tag (:td){
              extra_column[:tag_proc].call(acc.call(elem, :id))
            }).to_s.html_safe
          end
          column_content
        end
      }.join().html_safe
    end
    content_tag(:table, thead.concat(tbody), :class=>"table", :id => id)
  end

  def zone_selection_table(columns, collection = {}, id = nil)
    standard_table(columns, collection, id, modelAccessor, choose_zone_column )
  end

  def ad_selection_table(columns, collection = {}, id = nil)
    standard_table(columns, collection, id, modelAccessor, choose_ad_column )
  end

  def ad_for_zone_table(columns, collection, id)
    standard_table(columns, collection, id, modelAccessor, choose_ad_for_zone_column(id) )
  end

  def inspect_id_table (columns, collection, id = nil)
    standard_table(columns, collection, id, hashAccessor, inspect_id_column)
  end
  
  def clickable_table(columns, collection = {}, id = nil)
    standard_table(columns, collection, id, modelAccessor, empty_column, zone_onclick_html)
  end 

  def categories_table
    categories = getCategories
    
    return if categories.length == 0
    
    counter = 0
    childcounter = 0

    tbody = content_tag :tbody do
      categories.collect { |category|
        counter = childcounter
        ct = content_tag(:tr, :class => "treegrid-#{counter += 1}")do
          ict = content_tag(:td, category['mainCategory'])
          ict += content_tag(:td)do
            check_box_tag(category['mainCategory'],nil,false, :onclick => "toggleCategory('#{category['mainCategory']}',this.checked);")
          end
        end
        childcounter = counter
        ct += (category['subCategories'].collect{ |subCategory|
          content_tag(:tr, :class => "treegrid-#{childcounter += 1} treegrid-parent-#{counter}")do
            ict = content_tag(:td, subCategory)
            ict += content_tag(:td) do
              check_box_tag(subCategory,nil,false, :onclick => "toggleCategory('#{subCategory}',this.checked);")
            end
          end
        }.join().html_safe)
      }.join().html_safe
    end

    content_tag(:table, tbody, :class => "table tree")
  end
end
