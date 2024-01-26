Root =
{
    Type = "Control",
    Name = "GXWheelBrake",
    Style = "Normal",
    Position = { 0, 0, },
    Size = { 0, 0, },
    Children =
    {
        {
            Type = "SliderBar",
            Name = "BrakeSlider",
            Style = "Panel",
            ValIsPercentage = false,
            Static =
            {
                Texture = path .. "/empty.png",
                Control =
                {
                    ClipChildren = true,
                    Position = { 400, 555, },
                    Size = { 300, 30, },
                    TabStop = 6,
                    Children =
                    {
                        {
                            Type = "Button",
                            Name = "DownButton",
                            Style = "SliderBar",
                            Static =
                            {
                                Texture = "slider-arrow-left",
                                Control =
                                {
                                    Position = { 7.5, 9, },
                                    Size = { 12, 12, },
                                    Anchor = 3,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "UpButton",
                            Style = "SliderBar",
                            Static =
                            {
                                Texture = "slider-arrow-right",
                                Control =
                                {
                                    Position = { 66, 9, },
                                    Size = { 12, 12, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "SliderTrack",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderTrack.dds",
                                Control =
                                {
                                    Position = { 15, 9, },
                                    Size = { 58.5, 25, },
                                    Anchor = 2,
                                },
                            },
                        },



                        {
                            Type = "Button",
                            Name = "ScaleMarker1",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 13.35, 18, },
                                    Size = { 6, 5, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker2",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 34.515, 18.5, },
                                    Size = { 6, 6, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker3",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 55.68, 19, },
                                    Size = { 6, 7, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker4",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 76.845, 19.5, },
                                    Size = { 6, 8, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker5",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 98.01, 20, },
                                    Size = { 6, 9, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker6",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 119.175, 20.5, },
                                    Size = { 6, 10, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker7",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 140.34, 21, },
                                    Size = { 6, 11, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker8",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 161.505, 21.5, },
                                    Size = { 6, 12, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker9",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 182.67, 22, },
                                    Size = { 6, 13, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker10",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 203.835, 22.5, },
                                    Size = { 6, 14, },
                                    Anchor = 2,
                                },
                            },
                        },
                        {
                            Type = "Button",
                            Name = "ScaleMarker11",
                            Style = "Normal",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 225, 23, },
                                    Size = { 6, 15, },
                                    Anchor = 2,
                                },
                            },
                        },



                        {
                            Type = "Button",
                            Name = "SliderBar",
                            Style = "SliderBar",
                            Static =
                            {
                                Texture = "ui/textures/SliderBar.dds",
                                Control =
                                {
                                    Position = { 30, 9, },
                                    Size = { 4, 20, },
                                    Anchor = 8,
                                },
                            },
                        },
                        -- {
                        --     Type = "Text",
                        --     Name = "ValueText",
                        --     Style = "Normal",
                        --     Text = "0%",
                        --     Control =
                        --     {
                        --         Position = { 197, 9, },
                        --         Size = { 45.14, 12, },
                        --         Anchor = 3,
                        --     },
                        -- },
                    },
                },
            },
        },
    }
}
