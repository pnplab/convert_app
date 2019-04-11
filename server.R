###     -*- Coding: utf-8 -*-          ###
### Analyste Charles-Edouard Giguere   ###

### Shiny application for the article: correspondance between the SANS/SAPS and
### the PANSS.

### Server side. 

options(stringsAsFactors = FALSE)
cor.df <- read.csv("./RES.COR.csv")
makeReactiveBinding("plot_counter") 
plot_counter <- 0

server <- function(input, output) {
    output$ORDER <- renderTable({
        ORD <- NULL
        if(length(input$CORR1) != 0){
            xy <- strsplit(input$CORR1, " => ")
            ORD <- data.frame("ORDER OF INPUT VARS" =
                                  unique(unlist(
                                      lapply(xy,
                                             function(x) x[1])
                                  )),
                              check.names = FALSE)
        }
        ORD
    })
    
    output$OUT1 <- renderTable({
        f1 <- input$FIN      
        if(is.null(f1))
            return(NULL)      
        in.df <- read.table(f1$datapath, sep = ",",
                            skip = ifelse(input$fl,1,0))     
        xy <- unlist(strsplit(input$CORR1, split = " => "))
        xy <- as.data.frame(matrix(xy, ncol = 2, byrow = TRUE))
        names(in.df) <- unique(xy[,1])
        beta <- cor.df[cor.df$x %in% xy[,1] & cor.df$y %in% xy[,2],3:4]
        for(i in 1:dim(xy)[1])
            in.df[,xy[i,2]] <- beta[i,1] + beta[i,2]*in.df[,xy[i,1]]       
        in.df
    })

    output$Download <- downloadHandler(
        filename = function(){
            sprintf("OUTPUT_%s", input$FIN$name)
        },
        content = function(file){
            f1 <- input$FIN
            if(is.null(f1))
                return(NULL)            
            in.df <- read.table(f1$datapath, sep = ",",
                                skip = ifelse(input$fl,1,0))
            xy <- unlist(strsplit(input$CORR1, split = " => "))
            xy <- as.data.frame(matrix(xy, ncol = 2, byrow = TRUE))
            names(in.df) <- unique(xy[,1])
            beta <- cor.df[cor.df$x %in% xy[,1] & cor.df$y %in% xy[,2],3:4]
            for(i in 1:dim(xy)[1])
                in.df[,xy[i,2]] <- beta[i,1] + beta[i,2]*in.df[,xy[i,1]]       
            write.csv(in.df, file)
        })
    observe({
        if (is.null(input$FIN) | is.null(input$CORR1) |
            (!is.null(input$CORR1) & length(input$CORR1)==1)) {
            shinyjs::hide("Next")
        } else {
            shinyjs::show("Next")
        }
    })
    observeEvent(input$Next,{        
        plot_counter <<- (plot_counter + 1) %% length(input$CORR1)
        output$FIG1  <- renderPlot({plot_i()})
        print(sprintf("Compteur: %d", plot_counter))
    })
    plot_i <- reactive({
        
        f1 <- input$FIN
        if(is.null(f1))
            return(NULL)            
            in.df <- read.table(f1$datapath, sep = ",",
                                skip = ifelse(input$fl,1,0))
            print(in.df)
            xy <- unlist(strsplit(input$CORR1, split = " => "))
            xy <- as.data.frame(matrix(xy, ncol = 2, byrow = TRUE))
            print(xy)
            names(in.df) <- unique(xy[,1])
            beta <- cor.df[cor.df$x %in% xy[,1] & cor.df$y %in% xy[,2],3:4]
            for(i in 1:dim(xy)[1])
                in.df[,xy[i,2]] <- beta[i,1] + beta[i,2]*in.df[,xy[i,1]]     

                xl <- c(ifelse(grepl("SA.S",xy[plot_counter+1,1]),0, 1),
                        ifelse(grepl("SA.S",xy[plot_counter+1,1]),5, 7))
                yl <- c(ifelse(grepl("SA.S",xy[plot_counter+1,2]),0, 1),
                        ifelse(grepl("SA.S",xy[plot_counter+1,2]),5, 7))
                plot.df <- in.df[,c(xy[plot_counter+1,2], xy[plot_counter+1,1])]
                plot.df$w <- ave(!is.na(plot.df[,1]) & !is.na(plot.df[,1]),
                                 plot.df[,1], plot.df[,2], FUN = sum, na.rm = TRUE)
                plot(1,1, type = "n",             
                     xlim = xl, ylim = yl,
                     xlab = xy[plot_counter+1,1], ylab = xy[plot_counter+1,2])
                grid()
                points(as.formula(sprintf("%s ~ %s", xy[plot_counter+1,2],
                                          xy[plot_counter+1,1])), data = plot.df,
                       cex = sqrt(plot.df$w), pch = 19, col = 2,
                       xlim = xl, ylim = yl)
                
    })
    output$FIG1 <- renderPlot({
        plot_i()
    })
    
}


### Debug help values.
### in.df <- read.csv("./PANSS_2_input.csv")
### input  <- list(CORR1 = c("PANSS_negative => SANS_composite", "PANSS_positive => SAPS_composite"))
