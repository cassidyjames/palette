project(
    'com.github.cassidyjames.palette',
    'vala', 'c',
    version: '4.0.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language:'c')

asresources = gnome.compile_resources(
    'as-resources', 'data/gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

executable(
    meson.project_name(),
    asresources,
    'src/Application.vala',
    'src/Colors.vala',
    'src/MainWindow.vala',
    'src/MiniWindow.vala',
    'src/Widgets/ColorButton.vala',
    'src/Widgets/ColorVariant.vala',
    dependencies: [
        dependency('gee-0.8'),
        dependency('glib-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        meson.get_compiler('c').find_library('m', required : false)
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
