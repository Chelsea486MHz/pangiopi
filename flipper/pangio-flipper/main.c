int32_t hello_world_app() { 
    FuriMessageQueue* event_queue = furi_message_queue_alloc(8, sizeof(PluginEvent)); 
 
    // Set system callbacks
    ViewPort* view_port = view_port_alloc(); 
    view_port_draw_callback_set(view_port, render_callback, NULL);
    view_port_input_callback_set(view_port, input_callback, event_queue);
 
    // Open GUI and register view_port
    Gui* gui = furi_record_open("gui"); 
    gui_add_view_port(gui, view_port, GuiLayerFullscreen);
}