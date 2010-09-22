module Netzke
  # == Window
  # Ext.Window-based component able to nest other Netzke components
  # 
  # == Features
  # * Persistent position and dimensions
  # 
  # == Instance configuration
  # <tt>:item</tt> - nested Netzke component, e.g.:
  #     
  #     netzke :window, :item => {:class_name => "GridPanel", :model => "User"}
  class Window < Component::Base
    # Based on Ext.Window, naturally
    def self.js_base_class
      "Ext.Window"
    end
    
    # Extends the JavaScript class
    def self.js_properties
      {
        # we nest component inside the "fit" layout
        :layout => "fit",
        
        # default width and height
        :width => 300, 
        :height => 200,
        
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            // superclass' initComponent
            #{js_full_class_name}.superclass.initComponent.call(this);
            
            // set the move and resize events after window is shown, so that they don't fire at initial rendering
            this.on("show", function(){
              this.on("move", this.onMoveResize, this);
              this.on("resize", this.onMoveResize, this);
            }, this);

            // instantiate the component
            if (this.itemConfig){
              this.instantiateChild(this.itemConfig);
            }
          }
        END_OF_JAVASCRIPT
      
        :on_move_resize => <<-END_OF_JAVASCRIPT.l,
          function(){
            var x = this.getPosition()[0], y = this.getPosition()[1], w = this.getSize().width, h = this.getSize().height;

            // Don't bother the server twice when both move and resize events are fired at the same time
            // (which happens when the left or upper window border is dragged)
            if (this.moveResizeTimer) {clearTimeout(this.moveResizeTimer)};
            
            this.moveResizeTimer = (function(sizeAndPosition){
              this.setSizeAndPosition(sizeAndPosition); // API call
            }).defer(10, this, [{x:x, y:y, w:w, h:h}]); // 10ms should be enough
          }
        END_OF_JAVASCRIPT
        
      }
    end
    
    # Processing API calls from client
    api :set_size_and_position
    def set_size_and_position(params)
      Rails.logger.debug "!!! IMPLEMENT ME (set_size_and_position)\n"
      # update_persistent_ext_config(
      #   :x => params[:x].to_i, 
      #   :y => params[:y].to_i, 
      #   :width => params[:w].to_i, 
      #   :height => params[:h].to_i
      # )
      {}
    end
  end
end