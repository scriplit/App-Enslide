package App::Enslide;

our $VERSION = '0.01';

use 5.008001;
use strict;
use warnings;
use Getopt::Long;
use Path::Class;
use Markdent::Simple::Fragment;
use open ':encoding(utf8)';

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	return $self;
}

sub parse {
	my ( $self, @args ) = @_;
	local @ARGV = @args;

	$self->{file}  = 'presentation.md';
	$self->{title} = 'Presentation';
	$self->{hl}  = 'magula';
	$self->{css} = 'none';

	my $result = GetOptions(
		'title|t=s'       => \$self->{title},
		'css|c=s'         => \$self->{css},
		'highlightJS|j=s' => \$self->{hl},
		'out|o=s'         => \$self->{out},
		'help|h'          => \$self->{help}
	);
	
	$self->{file} = $ARGV[0] if ( defined $ARGV[0] );
}

sub want_help {
	my $self = shift;
	return $self->{help};
}

sub run {

	my $self = shift;

	if ( ( $self->{css} ne 'none' ) && ( !-f $self->{css} . '.css' ) ) {
		print STDERR "Warning: can't find " . $self->{css} . ".css!\n";
	}
	my $hjs = file( "styles", $self->{hl} . '.css' );
	if ( !-f $hjs ) {
		print STDERR "Warning: can't find HighlightJS style " . $self->{hl} . ".css!\n";
	}

	if ( !defined $self->{out} ) {
		my ($basename) = ( $self->{file} =~ /(.*)\./ );
		$self->{out} = $basename . '.html';
	}

	die ("$0: No markdown file given.") if ( !-f $self->{file} );
	open( my $fo, '>', $self->{out} )
	  || die "Can't open output file!\n";

	my $md = file($self->{file})->slurp;
	print $md . "\n";

	my $parser = Markdent::Simple::Fragment->new();
	my $ct     = $parser->markdown_to_html(
		markdown => $md,
		dialect  => 'GitHub'
	);

	my $html = htmlTemplate();
	$html =~ s/%%TITLE%%/$self->{title}/g;
	$html =~ s/%%CONTENT%%/$ct/g;
	$html =~ s/%%STYLE%%/$self->{hl}/g;

	if ( $self->{css} eq 'none' ) {
		$html =~ s/%%CSS%%//g;
	}
	else {
		my $css = $self->{css};
		$html =~ s/%%CSS%%/<link rel="stylesheet" href="$css.css">/g;
	}
	print $fo $html;
	close $fo;
}


sub htmlTemplate {

	return << '_END_HTML';
<!DOCTYPE html> 
<html> 
<head>
	<meta charset="UTF-8"> 
	<title>%%TITLE%%</title> 
	<link rel="stylesheet" href="jquery.mobile-1.3.2.min.css" />
	<script src="jquery-1.8.2.min.js"></script>
	<script src="highlight.pack.js"></script>
    <link rel="stylesheet" href="styles/%%STYLE%%.css">
    <script>
        $(function(){
        	var ensheet = function(){
	        	var $all = $("p, pre");
	        	$all.filter(":even").addClass("slide");
	        	$all.filter(":odd").addClass("slcomment");
	        	$(".slide").each(function(n){
	        		$(this).wrap("<div class=\"sheet\" id=\"sheet" + n + "\"></div>");
	        	});
	        	$(".slcomment").each(function(n){
	        		$(this).appendTo("#sheet" + n);
	        	});
        	};
			var enslide = function(){
	            n = 1;
	            $(".sheet").hide();
	            $.slide_active = 0;
	            $.slide_count = $(".sheet").length;
	            $('body').keyup(function(e) {
	                if(e.keyCode == '37') {
	                    //alert('prev');
	                    if ($.slide_active > 1) {
	                        $('#sheet' + $.slide_active).hide();
	                        $('#sheet' + ($.slide_active-1)).show();
	                        $.slide_active -= 1;
	                    }                    
	                }
	                else if(e.keyCode == '39') {
	                    //alert('next');
	                    var id_cur = '#sheet' + $.slide_active;
	                    var id_next = '#sheet' + ($.slide_active+1);
	                    if ($.slide_active > 0) {
	                        $(id_cur).hide();
	                    }
	                    if ($.slide_active < $.slide_count ) {                        
	                        $(id_next).show();
	                        $.slide_active += 1;
	                    }
	                }
	                else if(e.keyCode == '80'){
	                	enprint();
	                }
	            });        		
        	};
        	var enprint = function(){
        		$(".sheet").show();
        		window.print();
        		enslide();
        	};
        	ensheet();
        	enslide();
        	hljs.initHighlightingOnLoad();
        	$( "#hint" ).fadeIn( 400 ).delay(2000).fadeOut(1000);
        });
    </script>
    <style>
	@media screen,print {
		body {
		    background-attachment: fixed;
	    	background-color: black;
	    	background-position: center center;
	    	background-repeat: no-repeat; 
	    	background-size: 100% 100%;
		}
	    
	    .sheet {
		  width: 1070px;
		  height: 600px;
		}
	    
		.slide {
			width:100%;
			height:500px;
			font-family:sans-serif;
			font-size:40px;
			word-wrap: normal;
			margin-top: 50px;
			margin-bottom: 0px;
			display:-moz-box;
			-moz-box-pack:center;
			-moz-box-align:center; 
		}      
	
		pre code {
	    	font-size: 60%;
	    	height: 60%;
	    	width: 100%;
	    	max-height: 450px;
	    	max-width: 800px;
	    	overflow: auto;
	    	padding: 0px;
	    }
	}
	@media screen {
		.slcomment {
			display: none;
		}
		
		#hint {
			width:100%;
			height:500px;
			font-family:sans-serif;
			font-size:40px;
			word-wrap: normal;
			margin-top: 50px;
			margin-bottom: 0px;
			display:-moz-box;
			-moz-box-pack:center;
			-moz-box-align:center;		}
	}
	@media print {
		.sheet {
		  page-break-after: always;
		}
		.slcomment {
		  height: 100px;
		  border-top: 2px solid #CCCCCC;
		  padding-top: 10px;
		  font-size: 12px;
		  font-family: fantasy;
		}
	}
    </style>
    %%CSS%%
</head> 
<body> 

%%CONTENT%%

	<div id="hint">
		Arrow keys to navigate, 'p' to print the whole presentation. 
	</div>
</body>
</html>

_END_HTML

}

1;

__END__

