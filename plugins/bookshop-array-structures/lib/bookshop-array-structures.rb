require "jekyll"
require "toml-rb"

module Bookshop
  class ArrayStructures
    def self.get_story_name(path)
      basename = get_component_type(path)
      return basename.split(/-|\//).map(&:capitalize).join(" ")
    end

    def self.get_component_type(path)
      result = path.split(".").first;
      pathParts = path.split(".").first.split("/")
      if pathParts.length >= 2 && pathParts[pathParts.length-1] === pathParts[pathParts.length-2]
        pathParts.pop
        result = pathParts.join("/")
      end
      return result
    end

    def self.handle_story(story, site)
      result = {};
      story.each_pair {|key, value|
          if result.has_key?(key) && storyname != "defaults"
            next
          end

          if key.include? "--repeat"
            new_key = key.split("--").first
            result[new_key] = []
            site.config["_array_structures"][new_key] ||= {
              "values" => []
            }

            label = new_key.split("_").map(&:capitalize).join(" ")
            if site.config["_array_structures"][new_key]["values"].select{|value| value["label"] == label}.length > 0
              next
            end
            site.config["_array_structures"][new_key]["values"].push({
              "label" => label,
              "value" => value
            })
          elsif key.include? "--select" or key.include? "--radio" or key.include? "--inline-radio"
            new_key = key.split("--").first
            result[new_key] = nil
            site.config["_select_data"][new_key+"s"] = []
            value.each_value{|option|
              if site.config["_select_data"][new_key+"s"].select{|value| value == option}.length > 0
                next
              end
              site.config["_select_data"][new_key+"s"].push(option)
            }
          elsif key.include? "--multi-select" or key.include? "--check" or key.include? "--inline-check"
            new_key = key.split("--").first
            result[new_key] = []
            site.config["_select_data"][new_key] = []
            value.each_value{|option|
              if site.config["_select_data"][new_key].select{|value| value == option}.length > 0
                next
              end
              site.config["_select_data"][new_key].push(option)
            } 
          else
            result[key] = value
          end
        }
        return result
    end

    def self.transform_component(path, component, site)
      result = { "value" => {} }
      result["label"] = get_story_name(path)
      result["array_structures"] = ["components"];
      result["value"]["_component_type"] = get_component_type(path)
      component.each_pair { |storyname, story|
        if storyname == "meta"
          result.merge!(story)
        else
          result["value"].merge!(handle_story(story, site))
        end
      }
      return result
    end

    def self.build_array_structures(site)
      base_path = "_bookshop/components/"
      if !site.theme.nil?
        base_path = site.theme.root + "/_bookshop/components/"
      end
      site.config["_select_data"] ||= {}
      site.config["_array_structures"] ||= {}
      Dir.glob("**/*.stories.{toml,tml,tom,tm}", base: base_path).each do |f|
        component = TomlRB.load_file(base_path + f)
        transformed_component = transform_component(f, component, site)
        array_structures = transformed_component.delete("array_structures")
        array_structures.each{|key|
          site.config["_array_structures"][key] ||= {}
          site.config["_array_structures"][key]["values"] ||= []
          site.config["_array_structures"][key]["values"].push(transformed_component)
        }
      end
      puts site.config["_array_structures"].inspect
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  Bookshop::ArrayStructures.build_array_structures(site)
end
