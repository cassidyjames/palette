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

        .fg-%s-%i {
            color: %s;
        }
    """;
    private const int VARIANTS[] = {100, 300, 500, 700, 900};
    private const string BLACK = "#000";
    private const string WHITE = "#fff";

    public Color color { get; construct; }

    public ColorButton (Color color, int size = 128) {
        Object (
            height_request: size,
            width_request: size,
            color: color,
            tooltip_text: color.pretty ()
        );
    }

    construct {
        var color_context = get_style_context ();
        color_context.add_class ("circular");

        var color_grid = new Gtk.Grid ();
       color_grid.width_request = 200;

        var color_menu = new Gtk.Popover (this);
        color_menu.add (color_grid);
        color_menu.position = Gtk.PositionType.RIGHT;

        var title = new Gtk.Label (color.pretty ());
        title.halign = Gtk.Align.START;
        title.hexpand = true;
        title.margin_start = title.margin_end = 6;
        title.margin_top = 6;

        var title_context = title.get_style_context ();
        title_context.add_class (Granite.STYLE_CLASS_H2_LABEL);
        title_context.add_class ("fg-%s-%i".printf (color.style_class (), 900));

        var toggle = new Granite.ModeSwitch.from_icon_name ("preferences-color-symbolic", "applications-development-symbolic");
        toggle.primary_icon_tooltip_text = (_("Hex value"));
        toggle.secondary_icon_tooltip_text = (_("Gtk.CSS color constant"));
        toggle.margin_start = 6;
        toggle.margin_top = 6;
        toggle.valign = Gtk.Align.CENTER;
        toggle.get_style_context ().add_class ("fg-%s-%i".printf (color.style_class (), 700));

        var uses_label = new Gtk.Label (_("<b>Uses:</b> %s").printf (color.uses ()));
        uses_label.margin = 6;
        uses_label.max_width_chars = 30;
        uses_label.use_markup = true;
        uses_label.wrap = true;
        uses_label.xalign = 0;
        uses_label.get_style_context ().add_class ("fg-%s-%i".printf (color.style_class (), 900));

        int row = 1;
        foreach (unowned int variant in VARIANTS) {
            var color_variant = new ColorVariant (color, variant, color_menu, toggle);
            color_grid.attach (color_variant, 0, row++, 2);
            add_styles (color.style_class (), variant, color.hex ()[variant]);
        }

        int title_row = row++;
        color_grid.attach (title, 0, title_row);
        color_grid.attach (toggle, 1, title_row);
        color_grid.attach (uses_label, 0, row++, 2);

        color_context.add_class ("%s-%i".printf (color.style_class (), 500));
        color_grid.show_all ();
        popover = color_menu;
    }

    private void add_styles (string class_name, int variant, string bg_color) {
        var gdk_white = Gdk.RGBA ();
        gdk_white.parse (WHITE);

        var gdk_black = Gdk.RGBA ();
        gdk_black.parse (BLACK);

        var gdk_bg = Gdk.RGBA ();
        gdk_bg.parse (bg_color);

        var contrast_white = contrast_ratio (
            gdk_bg,
            gdk_white
        );
        var contrast_black = contrast_ratio (
            gdk_bg,
            gdk_black
        );

        var fg_color = WHITE;

        // NOTE: We cheat and add 3 to contrast when checking against black,
        // because white generally looks better on a colored background
        if ( contrast_black > (contrast_white + 3) ) {
            fg_color = BLACK;
        }

        var provider = new Gtk.CssProvider ();
        try {
            var colored_css = BUTTON_CSS.printf (
                class_name,
                variant,
                bg_color,
                fg_color,

                class_name,
                variant,
                bg_color
            );
            provider.load_from_data (colored_css, colored_css.length);

            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        } catch (GLib.Error e) {
            return;
        }
    }

    private double contrast_ratio (Gdk.RGBA bg_color, Gdk.RGBA fg_color) {
        var bg_luminance = get_luminance (bg_color);
        var fg_luminance = get_luminance (fg_color);

        if (bg_luminance > fg_luminance) {
            return (bg_luminance + 0.05) / (fg_luminance + 0.05);
        }

        return (fg_luminance + 0.05) / (bg_luminance + 0.05);
    }

    private double get_luminance (Gdk.RGBA color) {
        var red = sanitize_color (color.red) * 0.2126;
        var green = sanitize_color (color.green) * 0.7152;
        var blue = sanitize_color (color.blue) * 0.0722;

        return (red + green + blue);
    }

    private double sanitize_color (double color) {
        if (color <= 0.03928) {
            return color / 12.92;
        }

        return Math.pow ((color + 0.055) / 1.055, 2.4);
    }
}

