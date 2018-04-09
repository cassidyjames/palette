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

const string levels[] = {"100", "300", "500", "700", "900"};

public class ColorButton : Gtk.Button {
    public string class_name { get; construct; }
    public string human { get; construct; }

    public ColorButton (string class_name, string human) {
        Object (
            height_request: 128,
            width_request: 128,
            class_name: class_name,
            human: human,
            tooltip_text: human
        );
    }

    construct {
        var color_context = get_style_context ();
        color_context.add_class (class_name);
        color_context.add_class ("circular");

        var color_grid = new Gtk.Grid ();
        color_grid.width_request = 200;

        int i = 0;
        foreach (unowned string level in levels) {
            Gdk.RGBA rgba;
            string hex = "";

            bool found = color_context.lookup_color ("%s_%s".printf (class_name.up (), level), out rgba);
            if (found) {
                hex = "#%02x%02x%02x".printf ((int) (rgba.red * 255), (int) (rgba.green * 255), (int) (rgba.blue * 255));
            }

            var color = new Gtk.Label ("%s %s".printf (human, level));
            color.hexpand = true;
            color.height_request = 48;
            color.get_style_context ().add_class ("%s-%s".printf (class_name, level));

            var color_hex = new Gtk.Label (hex);
            color_hex.hexpand = true;
            color_hex.height_request = 48;
            color_hex.get_style_context ().add_class ("%s-%s".printf (class_name, level));

            color_grid.attach (color, 0, i, 1, 1);
            color_grid.attach (color_hex, 1, i, 1, 1);

            i++;
        }

        var color_menu = new Gtk.Popover (this);
        color_menu.add (color_grid);
        color_menu.position = Gtk.PositionType.BOTTOM;

        this.clicked.connect (() => {
            color_menu.popup ();
            color_menu.show_all ();
        });
    }
}
