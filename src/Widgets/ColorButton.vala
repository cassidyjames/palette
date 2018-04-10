/*
* Copyright (c) 2018 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class ColorButton : Gtk.MenuButton {
    private const string BUTTON_CSS = """
        .%s-%i {
            background: %s;
            color: %s;
        }
    """;
    private const int VARIANTS[] = {100, 300, 500, 700, 900};

    public Color color { get; construct; }
    
    public ColorButton (Color color) {
        Object (
            height_request: 128,
            width_request: 128,
            color: color,
            tooltip_text: color.to_string ()
        );
    }

    construct {
        var color_context = get_style_context ();
        color_context.add_class ("circular");

        var color_grid = new Gtk.Grid ();
       color_grid.width_request = 200;

        var color_menu = new Gtk.Popover (this);
        color_menu.add (color_grid);
        color_menu.position = Gtk.PositionType.BOTTOM;

        int i = 0;
        foreach (unowned int variant in VARIANTS) {
            var color_variant = new ColorVariant (color, variant, color_menu);
            color_grid.attach (color_variant, 0, i, 1, 1);
            add_styles (color.style_class (), variant, color.hex ()[variant], "#fff");
            i++;
        }

        color_context.add_class ("%s-%i".printf (color.style_class (), 500));
        color_grid.show_all ();
        popover = color_menu;
    }
    
    private void add_styles (string class_name, int variant, string bg_color, string fg_color) {
        var provider = new Gtk.CssProvider ();
        try {
            var colored_css = BUTTON_CSS.printf (class_name, variant, bg_color, fg_color);
            provider.load_from_data (colored_css, colored_css.length);

            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (GLib.Error e) {
            return;
        }
    }
}

