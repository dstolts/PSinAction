# Adapted from i1.wp.com/itfordummies.azurewebsites.net/wp-content/uploads/2015/05/IseSteroids-WPF-8.png"

function Get-Presentation
{
    param
    (
        [Parameter(Mandatory=$True)]
        [string] $XAML,
        [string[]]  $NamedElements,
        [switch] $PassThru
    )
    
    $reader = [System.XML.XmlReader]::Create([System.IO.StringReader]$XAML)        
    $result = [System.Windows.Markup.XAMLReader]::Load($reader)   

    foreach ($Name in $NamedElements)
    {
        $result | Add-Member NoteProperty -Name $Name -Value $result.FindName($Name) -Force
    }

    if ($PassThru)
    {
        $result
    }
    else
    {
        $result.ShowDialog()
    }
    
}

$xaml = @'

<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        Title="Tim's Awesome PowerShell Presentation" 
        MinHeight="600" MinWidth="450" 
        Background="AliceBlue"
        >
   <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
                <ResourceDictionary Source="c:\users\admin\desktop\AutoSequencer\Presentation\StylesDictionary.xaml" />
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
  </Window.Resources>
  
  <Grid Name="PrimaryGrid" Background="#E0F0FF">
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="155"/>
      <ColumnDefinition Width="155"/>
      <ColumnDefinition Width="*"/>
    </Grid.ColumnDefinitions>
    <Grid.RowDefinitions>
      <RowDefinition Height="46" />
      <RowDefinition Height="*"/>
      <RowDefinition Height="48" />
    </Grid.RowDefinitions>



    <Label Name="title0" 
           Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="3" 
           Style="{StaticResource MyTitleStyle}" Visibility="Visible"
           Content="Automate or Die, or Maybe Not!" />
    <Image Name="image0" Source="c:\users\admin\desktop\AutoSequencer\Presentation\ps101.png" 
        Grid.Row="1" Grid.Column="2" 
        Visibility="Visible" />
    <StackPanel Name="content0" Orientation="Vertical" VerticalAlignment="Center" Visibility="Visible"
        Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2">
        <TextBlock 
            Style="{StaticResource MyHeadingStyle}" >
             Pretty much everything you need to know about PS to get started.  
        </TextBlock>
        <TextBlock Style="{StaticResource WrapTBlkStyle}" >
             That and maybe Google.  Uh, I mean "Bing".
        </TextBlock>
    </StackPanel>

    <Label Name="title1" 
           Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="3" 
           Style="{StaticResource MyTitleStyle}" Visibility="Collapsed"
           Content="Here is a book I wrote:" />
    <Image Name="image1" Source="c:\users\admin\desktop\AutoSequencer\Presentation\PSBookFrontCover5.1.png" 
        Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2"  
        Width="300" Visibility="Collapsed" />
    <StackPanel Name="content1" Orientation="Vertical" VerticalAlignment="Center" Visibility="Collapsed"
        Grid.Row="1" Grid.Column="2">
        <TextBlock 
            Style="{StaticResource MyHeadingStyle}" >
             This is an awsome book that I wrote along with my daughter.  
        </TextBlock>
        <TextBlock Style="{StaticResource WrapTBlkStyle}" >
             It servers as a reference manual for documenting the Windows PowerShell used by Microsoft App-V.
             When we originally wrote the book for 5.0, the online help for the new App-V Powershell was
             REALLY, REALLY, REALLY bad.
        </TextBlock>
    </StackPanel>

    <Label Name="title2" 
           Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="2" 
           Style="{StaticResource MyTitleStyle}" Visibility="Collapsed"
           Content="Here is a trip I took:" 
           Foreground="Navy" HorizontalAlignment="Center"    />
     <Image Name="image2" Source="c:\users\admin\desktop\AutoSequencer\Presentation\Tim_Mangan_PDS_6.jpg" 
        Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="2"  Visibility="Collapsed" Margin="0,5,20,5" />
    <StackPanel Name="content2" Orientation="Vertical" VerticalAlignment="Center" Visibility="Collapsed"
            Grid.Row="1" Grid.Column="0">
        <TextBlock Name="textbox2a"
             Style="{StaticResource MyDetailStyle}" >
             So, we wrote the book, and the development team at Microsoft bought a copy and fixed up their documentation.
        </TextBlock>
        <TextBlock Name="textbox2b" 
            Style="{StaticResource WrapTBlkStyle}" >
             We continue to sell the book because apparently people like shelfware.
        </TextBlock>
        <TextBlock Name="textbox2c" 
            Style="{StaticResource WrapTBlkStyle}" >
            By the way, all of the people in this image are IT Admins in Culemborg in The Netherlands. 
            Sometimes they automate things.
        </TextBlock>
    </StackPanel>


    <Label Name="title3_2" 
           Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="3"  
           Style="{StaticResource MyTitleStyle}"  Visibility="Collapsed"
           Content="Evolution of Languages..."
    />
    <StackPanel Name="content3_2" Orientation="Horizontal" Visibility="Collapsed" VerticalAlignment="Center"
                Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3" >
        <Image Name="image3_2" Source="c:\users\admin\desktop\AutoSequencer\Presentation\Languages.png" Margin="5,0,0,10" />
        <StackPanel Orientation="Vertical" VerticalAlignment="Center">
            <TextBlock 
                 Style="{StaticResource MyHeadingStyle}">
                 A few "languages" over the years.
            </TextBlock>
            <TextBlock 
                Style="{StaticResource WrapTBlkStyle}">
                PowerShell is OBJECT oriented.
            </TextBlock>
            <TextBlock 
                Style="{StaticResource WrapTBlkStyle}">
                .Net Classes, Properties, Methods
            </TextBlock>
            <TextBlock 
                Style="{StaticResource WrapTBlkStyle}">
                PowerShell is OBJECT oriented.
            </TextBlock>
        </StackPanel>
    </StackPanel>


    <Label Name="title3" 
           Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="3"  
           Style="{StaticResource MyTitleStyle}"  Visibility="Collapsed"
           Content="About License Types..."
    />
    <StackPanel Name="content3" Orientation="Vertical" Visibility="Collapsed" VerticalAlignment="Center"
                Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3" >
        <TextBlock Style="{StaticResource MyHeadingStyle}" HorizontalAlignment="Center" >
                   PowerShell code is readily readable, and reused.  But you have to pay attention to the licenses!
        </TextBlock>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
            <StackPanel Orientation="Vertical" VerticalAlignment="Top">
                <Image Source="c:\users\admin\desktop\AutoSequencer\Presentation\MIT.png" Width="400"  />
                <TextBlock Style="{StaticResource WrapTBlkStyle}" Width="300" >
                    Generally, you can use, copy, and modify as you like, but provide must attribution and retain license.
                </TextBlock>
            </StackPanel>
            <StackPanel Orientation="Vertical" VerticalAlignment="Top">
                <TextBlock Style="{StaticResource MyDetailStyle}" Width="300" Height="140" >
                        Appache V2
                </TextBlock>
                <TextBlock Style="{StaticResource WrapTBlkStyle}" Width="300" >
                        Some protection for patents and intellectual property added.
                </TextBlock>
            </StackPanel>
            <StackPanel Orientation="Vertical" VerticalAlignment="Top">
                <TextBlock Style="{StaticResource MyDetailStyle}" Width="300" Height="140" >
                    GPL V3
                </TextBlock>
                <TextBlock Style="{StaticResource WrapTBlkStyle}" Width="300">
                        Might need to make all source code available?
                </TextBlock>
            </StackPanel>
        </StackPanel>
         <TextBlock Style="{StaticResource MyHeadingStyle}" HorizontalAlignment="Center" Foreground="Maroon" >
                   I am not a Lawyer, nor do I play one in presentations.  This is on you to understand.
        </TextBlock>
   </StackPanel>


    <Label Name="title4" 
           Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="2"  
           Style="{StaticResource MyTitleStyle}" Visibility="Collapsed"
           Content="Here is some PowerShell I wrote for this Keynote:" 
           Foreground="Navy" HorizontalAlignment="Center"  />
     <Image Name="image4" Source="c:\users\admin\desktop\AutoSequencer\Presentation\ps1.png" 
        Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="2"  Visibility="Collapsed" Margin="0,5,20,5" />
    <StackPanel Name="content4" Orientation="Vertical" VerticalAlignment="Center" Visibility="Collapsed"
            Grid.Row="1" Grid.Column="0">
        <TextBlock 
             Style="{StaticResource MyHeadingStyle}">
             I wrote this GUI Presentation as a PowerShell Application!
        </TextBlock>
        <TextBlock 
             Style="{StaticResource WrapTBlkStyle}">
             It uses XAML to produce the graphics and I added working buttons to control the graphics.
        </TextBlock>
        <TextBlock Name="textbox4psversion" 
            Style="{StaticResource WrapTBlkStyle}" >
        </TextBlock>
    </StackPanel>

    <Label Name="title5" 
           Grid.Row="0" Grid.Column="1" Grid.ColumnSpan="2"  
           Style="{StaticResource MyTitleStyle}"  Visibility="Collapsed"
           Content="Crap! It had errors" 
           Foreground="Red"   HorizontalAlignment="Center"  />
     <Image Name="image5" Source="c:\users\admin\desktop\AutoSequencer\Presentation\ps2.png" 
        Grid.Row="1" Grid.Column="1" Grid.ColumnSpan="2"  Visibility="Collapsed" Margin="0,5,20,5" />
    <StackPanel Name="content5" Orientation="Vertical" VerticalAlignment="Center" Visibility="Collapsed"
            Grid.Row="1" Grid.Column="0">
        <TextBlock 
             Style="{StaticResource WrapTBlkStyle}">
             Well the first attempt didn't go well. Not necessarily straightforward errors either. Xaml errors are listed with a line number that is an offset from the @.
        </TextBlock>
        <TextBlock 
             Style="{StaticResource WrapTBlkStyle}">
             You can use VSCode or various Visual Studio versions if you add in PowerShell additions to the tool. 
             In theory you can test in any of these tools, but in the end I just use the PowerShell ISE. 
             You can probably do it all in VSCode, but I'm not that smart yet.
        </TextBlock>
    </StackPanel>

    <Label Name="title6" 
           Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="3"  
           Style="{StaticResource MyTitleStyle}"  Visibility="Collapsed"
           Content="But we can get dynamic data into the GUI from our PowerShell code."
    />
    <StackPanel Name="content6" Orientation="Horizontal" Visibility="Collapsed"
                Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="3">
        <StackPanel Orientation="Vertical">
            <Label Name="textbox5a1" 
                    Foreground="DarkBlue"
                    VerticalAlignment="Center" Margin="5,0,10,10">
                    PowerShell Code:
            </Label>
            <ListView Name="textbox5a2" 
                    Margin="5,0,10,10" Foreground="DarkBlue"/>
        </StackPanel>
        <StackPanel Orientation="Vertical">
            <Label Name="textbox5b1"
                    Foreground="DarkBlue"
                    VerticalAlignment="Center" Margin="5,0,10,10">
                    PowerShell Results:
            </Label>
            <ListView Name="textbox5b2"  
                     Margin="5,0,10,10"/>
         </StackPanel>
    </StackPanel>



    <Label Name="title7" 
           Grid.Row="0" Grid.Column="0" Grid.ColumnSpan="3"  
           Style="{StaticResource MyTitleStyle}"  Visibility="Collapsed"
           Content="Using C# to call PowerShell"
    />
    <StackPanel Name="content7" Orientation="Vertical" VerticalAlignment="Top" Visibility="Collapsed"
        Grid.Row="1" Grid.Column="0" Grid.ColumnSpan="2" >
            <TextBlock
                Style="{StaticResource MyDetailStyle}">
                Here is some C# code I often use:
            </TextBlock>
            <Image  Source="c:\users\admin\desktop\AutoSequencer\Presentation\cGroups.png"/>
    </StackPanel>
    <Image Name="image7" Visibility="Collapsed"
            Grid.Row="1" Grid.Column="2"
            Source="c:\users\admin\desktop\AutoSequencer\Presentation\cSharp.png"
     />

    <Image Name="Auto8" Visibility="Collapsed"
            Grid.Column="0" Grid.Row="1" Grid.ColumnSpan="3"
            Source="c:\users\admin\desktop\AutoSequencer\Presentation\autoseq.png"
    />

    <Image Name="FinalSlide" Visibility="Collapsed"
            Grid.Column="0" Grid.Row="1" Grid.ColumnSpan="3"
            Source="c:\users\admin\desktop\AutoSequencer\Presentation\FinalSlide.png"
    />

    <Button Name="PrevButton1"  
            Grid.Row="2" Grid.Column="0"
            Content="Prev Slide" IsEnabled="False"  Height="28" Width="120"/>
    <Button Name="NextButton1"  
            Grid.Row="2" Grid.Column="1" 
            Content="Next Slide" IsEnabled="True" Height="28" Width="120"/>
    <Button Name="CloseButton1" 
            Grid.Row="2" Grid.Column="2" Content="Go Away"  Height="28" Width="120"/>
    <Label Name="PageNo" Style="{StaticResource MyTitleStyle}" FontSize="8"
            Grid.Row="2" Grid.Column="2" HorizontalAlignment="Right" VerticalAlignment="Bottom"
            Content="Slide 0">
            <Label.LayoutTransform>
                <TransformGroup>
                    <RotateTransform Angle="90"/>
                </TransformGroup>
            </Label.LayoutTransform>
    </Label>

  </Grid>
</Window>

'@

$window = Get-Presentation -XAML  $xaml -NamedElements  'title0', 'title1', 'title2', 'title3', 'title3_2', 'title4', 'title5', 'title6', 'title7', 'image0', 'image1', 'image2', 'image3_2', 'image4', 'image5', 'image7', 'Auto8', 'FinalSlide', 'content0', 'content1', 'content2',  'content3', 'content3_2', 'textbox4psversion', 'content4', 'content5', 'textbox5a1', 'textbox5a2', 'textbox5b1', 'textbox5b2', 'content6', 'content7', 'PrevButton1', 'NextButton1', 'CloseButton1', 'PageNo'  -PassThru


$window.PrevButton1.add_Click(
    {
        [System.Object]$sender = $args[0]
        [System.Windows.RoutedEventArgs]$e = $args[1]

        if ($window.title1.Visibility -eq "Visible")
        {
            $window.title1.Visibility = "Collapsed"
            $window.content1.Visibility = "Collapsed"
            $window.image1.Visibility = "Collapsed"
            
            $window.title0.Visibility = "Visible"
            $window.content0.Visibility = "Visible"
            $window.image0.Visibility = "Visible"
            
            $window.PageNo.Content = "Slide 0"

            $sender.IsEnabled = $False
        }
        elseif ($window.title2.Visibility -eq "Visible")
        {
            $window.title2.Visibility = "Collapsed"
            $window.content2.Visibility = "Collapsed"
            $window.image2.Visibility = "Collapsed"
            
            $window.title1.Visibility = "Visible"
            $window.content1.Visibility = "Visible"
            $window.image1.Visibility = "Visible"
            
            $window.PageNo.Content = "Slide 1"
        }
        elseif ($window.title3_2.Visibility -eq "Visible")
        {
            $window.title3_2.Visibility = "Collapsed"
            $window.content3_2.Visibility = "Collapsed"
            $window.image3_2.Visibility = "Collapsed"
            
            $window.title2.Visibility = "Visible"
            $window.content2.Visibility = "Visible"
            $window.image2.Visibility = "Visible"
        
            $window.PageNo.Content = "Slide 2"
        }
        elseif ($window.title3.Visibility -eq "Visible")
        {
            $window.title3.Visibility = "Collapsed"
            $window.content3.Visibility = "Collapsed"
            #$window.image3.Visibility = "Collapsed"
            
            $window.title3_2.Visibility = "Visible"
            $window.content3_2.Visibility = "Visible"
            $window.image3_2.Visibility = "Visible"
        
            $window.PageNo.Content = "Slide 3"
        }
        elseif ($window.title4.Visibility -eq "Visible")
        {
            $window.title4.Visibility = "Collapsed"
            $window.content4.Visibility = "Collapsed"
            $window.image4.Visibility = "Collapsed"
            
            $window.title3.Visibility = "Visible"
            $window.content3.Visibility = "Visible"
            #$window.image3.Visibility = "Visible"
            $window.PageNo.Content = "Slide 4"
        }        
        elseif ($window.title5.Visibility -eq "Visible")
        {
            $window.title5.Visibility = "Collapsed"
            $window.image5.Visibility = "Collapsed"
            $window.content5.Visibility = "Collapsed"
            #$window.textbox5a2.Visibility = "Collapsed"
            #$window.textbox5b1.Visibility = "Collapsed"
            #$window.textbox5b2.Visibility = "Collapsed"
            
            $window.title4.Visibility = "Visible"
            $window.content4.Visibility = "Visible"
            $window.image4.Visibility = "Visible"
            $window.PageNo.Content = "Slide 5"
        }
        elseif ($window.title6.Visibility -eq "Visible")
        {
            $window.title6.Visibility = "Collapsed"
            $window.content6.Visibility = "Collapsed"
            #$window.image6.Visibility = "Collapsed"
            
            $window.title5.Visibility = "Visible"
            $window.content5.Visibility = "Visible"
            $window.image5.Visibility = "Visible"
            #$window.StackPanel5.Visibility = "Visible"
            #$window.textbox5a1.Visibility = "Visible"
            #$window.textbox5a2.Visibility = "Visible"
            #$window.textbox5b1.Visibility = "Visible"
            #$window.textbox5b2.Visibility = "Visible"
            
            $window.PageNo.Content = "Slide 6"
        }           
        elseif ($window.title7.Visibility -eq "Visible")
        {
            $window.title7.Visibility = "Collapsed"
            $window.content7.Visibility = "Collapsed"
            $window.image7.Visibility = "Collapsed"
            
            $window.title6.Visibility = "Visible"
            $window.content6.Visibility = "Visible"
            #$window.image6.Visibility = "Visible"
            
            $window.PageNo.Content = "Slide 7"
        }           
        elseif ($window.Auto8.Visibility -eq "Visible")
        {
            $window.Auto8.Visibility = "Collapsed"
            
            $window.title7.Visibility = "Visible"
            $window.content7.Visibility = "Visible"
            $window.image7.Visibility = "Visible"
            
            $window.PageNo.Content = "Slide 8"
        }           
        elseif ($window.FinalSlide.Visibility -eq "Visible")
        {
            $window.FinalSlide.Visibility = "Collapsed"
            
            $window.Auto8.Visibility = "Visible"
            
            $window.PageNo.Content = "Slide 9"
            $window.NextButton1.IsEnabled = $True
        }           
        
   }
)
$window.NextButton1.add_Click(
    {
        [System.Object]$sender = $args[0]
        [System.Windows.RoutedEventArgs]$e = $args[1] 

        if ($window.title0.Visibility -eq "Visible")
        {
            $window.title0.Visibility = "Collapsed"
            $window.content0.Visibility = "Collapsed"
            $window.image0.Visibility = "Collapsed"
                  
            $window.title1.Visibility = "Visible"
            $window.content1.Visibility = "Visible"
            $window.image1.Visibility = "Visible"
            
            $window.PageNo.Content = "Slide 1"
        }
        elseif ($window.title1.Visibility -eq "Visible")
        {
            $window.title1.Visibility = "Collapsed"
            $window.content1.Visibility = "Collapsed"
            $window.image1.Visibility = "Collapsed"
                    
            $window.title2.Visibility = "Visible"
            $window.content2.Visibility = "Visible"
            $window.image2.Visibility = "Visible"
            
            $window.PageNo.Content = "Slide 2"
        }
        elseif ($window.title2.Visibility -eq "Visible")
        {
            $window.title2.Visibility = "Collapsed"
            $window.content2.Visibility = "Collapsed"
            $window.image2.Visibility = "Collapsed"                  

            if ($window.textbox4psversion.Text -cnotlike "*Let's test your*" )
            {
                $window.textbox4psversion.Text += "Let's test your system and check the PowerShell Version you are running. It seems to be version " + $host.Version.Major
            }

            $window.title3_2.Visibility = "Visible"
            $window.content3_2.Visibility = "Visible"
            $window.image3_2.Visibility = "Visible"
            $window.PageNo.Content = "Slide 3"
        }        
        elseif ($window.title3_2.Visibility -eq "Visible")
        {
            $window.title3_2.Visibility = "Collapsed"
            $window.content3_2.Visibility = "Collapsed"
            $window.image3_2.Visibility = "Collapsed"
                    
            $window.title3.Visibility = "Visible"
            $window.content3.Visibility = "Visible"
            #$window.image3.Visibility = "Visible"
            $window.PageNo.Content = "Slide 4"
        }        
         elseif ($window.title3.Visibility -eq "Visible")
        {
            $window.title3.Visibility = "Collapsed"
            $window.content3.Visibility = "Collapsed"
            #$window.image3.Visibility = "Collapsed"
                    
            $window.title4.Visibility = "Visible"
            $window.content4.Visibility = "Visible"
            $window.image4.Visibility = "Visible"
            $window.PageNo.Content = "Slide 5"
        }        
       elseif ($window.title4.Visibility -eq "Visible")
        {
            $window.title4.Visibility = "Collapsed"
            $window.content4.Visibility = "Collapsed"
            $window.image4.Visibility = "Collapsed"
                    
            $window.title5.Visibility = "Visible"
            $window.content5.Visibility = "Visible"
            $window.image5.Visibility = "Visible"
            #$window.StackPanel5.Visibility = "Visible"
            #$window.textbox5a1.Visibility = "Visible"
            #$window.textbox5a2.Visibility = "Visible"
            #$window.textbox5b1.Visibility = "Visible"
            #$window.textbox5b2.Visibility = "Visible"

            Get-SomePowerShell   
            
            $window.PageNo.Content = "Slide 6"
        }        
        elseif ($window.title5.Visibility -eq "Visible")
        {
            $window.title5.Visibility = "Collapsed"
            $window.content5.Visibility = "Collapsed"
            $window.image5.Visibility = "Collapsed"
            #$window.StackPanel5.Visibility = "Collapsed"
            #$window.textbox5a1.Visibility = "Collapsed"
            #$window.textbox5a2.Visibility = "Collapsed"
            #$window.textbox5b1.Visibility = "Collapsed"
            #$window.textbox5b2.Visibility = "Collapsed"
                    
            $window.title6.Visibility = "Visible"
            $window.content6.Visibility = "Visible"
            #$window.image6.Visibility = "Visible"
            $window.PageNo.Content = "Slide 7"
        }        
        elseif ($window.title6.Visibility -eq "Visible")
        {
            $window.title6.Visibility = "Collapsed"
            $window.content6.Visibility = "Collapsed"
            #$window.image6.Visibility = "Collapsed"
                    
            $window.title7.Visibility = "Visible"
            $window.content7.Visibility = "Visible"
            $window.image7.Visibility = "Visible"

            $window.PageNo.Content = "Slide 8"           
        }        
        elseif ($window.title7.Visibility -eq "Visible")
        {
            $window.title7.Visibility = "Collapsed"
            $window.content7.Visibility = "Collapsed"
            $window.image7.Visibility = "Collapsed"
                    
            $window.Auto8.Visibility = "Visible"
            $window.PageNo.Content = "Slide 9"

        }        
        elseif ($window.Auto8.Visibility -eq "Visible")
        {
            $window.Auto8.Visibility = "Collapsed"
                    
            $window.FinalSlide.Visibility = "Visible"
            $window.PageNo.Content = "Slide 10"

            $sender.IsEnabled = $False
        }        
        
        $window.PrevButton1.IsEnabled = $True
    }
)

$window.CloseButton1.add_Click(
    {
        [System.Object]$sender = $args[0]
        [System.Windows.RoutedEventArgs]$e = $args[1]
        $window.close()
    }
)

function Get-SomePowerShell
{
            $d1 = Get-Date
            $d2 = "Date:          " + $d1
            $VM1 = Get-VMHost
            $VM2 = "Host:         " + $VM1.Name
            $VM3 = "Mem Capacity: " + $VM1.MemoryCapacity
            $VM4 = "Processors:   " + $VM1.LogicalProcessorCount

            $window.textbox5a2.Items.Clear()
            $window.textbox5b2.Items.Clear()
            $window.textbox5a2.AddChild( "Get-Date")
            $window.textbox5b2.AddChild( $d2) 
            $window.Textbox5a2.AddChild( '$VM1 = Get-VMHost' )
            $window.textbox5b2.AddChild( " " ) 
            $window.Textbox5a2.AddChild( '$VM1.Name' )
            $window.textbox5b2.AddChild( $VM2 ) 
            $window.Textbox5a2.AddChild( '$VM1.MemoryCapacity' )
            $window.textbox5b2.AddChild( $VM3 ) 
            $window.Textbox5a2.AddChild( '$VM1.LogicalProcessorCount' )
            $window.textbox5b2.AddChild( $VM4 ) 
            $window.textbox5a2.AddChild( " " ) 
            $window.textbox5b2.AddChild( " " ) 
            $window.Textbox5a2.AddChild( 'Get-AppVClientPackage -All | ForEach-Object { Write-Host $_.Name  $_.PackageSize $_.PercentLoaded } ')
            Get-AppVClientPackage -All | ForEach-Object { $window.textbox5b2.AddChild($_.Name + "  " + $_.PackageSize + "  " + $_.PercentLoaded + "%") }

}
$window.ShowDialog()
