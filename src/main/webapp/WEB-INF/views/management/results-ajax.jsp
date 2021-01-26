<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>

<c:if test="${forpdf == null}">
	<script type="text/javascript"> 
		var statisticsrequestid = null;
		function loadStatisticsAsync(publication)
		{
		
			$(".ajaxloaderimage").show();
			$(".loadstatisticsbutton").hide();
			
				var s = "active=${active eq true}&allanswers=${allanswers eq true}";	
				
				if (publication)
				{
					s += "&publicationmode=true";	
				}
				
				if (statisticsrequestid != null)
				{
					s += "&statisticsrequestid=" + statisticsrequestid;	
				}
				
				$.ajax({
					type:'GET',
					  url: "${contextpath}/${form.survey.shortname}/management/statisticsJSON",
					  dataType: 'json',
					  data: s,
					  cache: false,
					  success: function( statistics ) {
						  if (statistics == null)
						  {
							//this means the asynchronous computation has been started
							setTimeout(function(){ loadStatisticsAsync(publication); }, 10000);
							return;
						  }
						  
						  if (statistics.requestID != null)
						  {
							  statisticsrequestid = statistics.requestID;
							  setTimeout(function(){ loadStatisticsAsync(publication); }, 10000);
							  return;
						  }
						  
						  $(".deactivatedstatexports").hide();
						  $(".activatedstatexports").show();	
						  
						  $(".statRequestedRecords").each(function(){
							 var id = $(this).attr("data-id");
							 if (statistics.requestedRecords[id] != null)
							 {
							 	$(this).html(statistics.requestedRecords[id]);
							 	$(this).closest("tr").attr("data-value",statistics.requestedRecords[id]);
							 }
						  });
						  
						  $(".statRequestedRecordsPercent").each(function(){
							 var id = $(this).attr("data-id");
							 if (statistics.requestedRecords[id] != null)
							 $(this).html(statistics.requestedRecordsPercent[id].toFixed(2) + " %");
						  });
						  
						  $(".chartRequestedRecordsPercent").each(function(){
								 var id = $(this).attr("data-id");
								 if (statistics.requestedRecords[id] != null)
								 {
									 $(this).css("width", statistics.requestedRecordsPercent[id].toFixed(2) + "%");
									 $(this).closest("tr").attr("data-value",statistics.requestedRecords[id]);
								 }								
							  });
						  
						  $(".statRequestedRecordsScore").each(function(){
								 var id = $(this).attr("data-id");
								 if (statistics.requestedRecordsScore[id] != null)
								 {
								 	$(this).html(statistics.requestedRecordsScore[id]);
								 	$(this).closest("tr").attr("data-value",statistics.requestedRecordsScore[id]);
								 }
							  });
						  
						  $(".statRequestedRecordsPercentScore").each(function(){
								 var id = $(this).attr("data-id");
								 if (statistics.requestedRecordsScore[id] != null)
								 $(this).html(statistics.requestedRecordsPercentScore[id].toFixed(2) + " %");
							  });
						  
						  $(".chartRequestedRecordsPercentScore").each(function(){
								 var id = $(this).attr("data-id");
								 if (statistics.requestedRecordsScore[id] != null)
								 {
									 $(this).css("width", statistics.requestedRecordsPercentScore[id].toFixed(2) + "%");
									 $(this).closest("tr").attr("data-value",statistics.requestedRecordsScore[id]);
								 }								
							  });
						 
						  $(".statMeanScore").html(roundToTwo(statistics.meanScore) + '&#x20;<spring:message code="label.of" />&#x20;' + statistics.maxScore + '&#x20;<spring:message code="label.points" /> (' + roundToTwo(statistics.maxScore == 0 ? 0 : statistics.meanScore / statistics.maxScore * 100) + '%)');
						  $(".statBestScore").html(statistics.bestScore + '&#x20;<spring:message code="label.of" />&#x20;' + statistics.maxScore + '&#x20;<spring:message code="label.points" /> (' + roundToTwo(statistics.maxScore == 0 ? 0 : statistics.bestScore / statistics.maxScore * 100) + '%)');
						  $(".statTotal").html(statistics.total);
						  
						  $(".statMeanSectionScore").each(function(){
							  var id = $(this).attr("data-id");							  
							  $(this).html(roundToTwo(statistics.meanSectionScore[id]) + '&#x20;<spring:message code="label.of" />&#x20;' + statistics.maxSectionScore[id] + '&#x20;<spring:message code="label.points" /> (' + roundToTwo(statistics.maxSectionScore[id] == 0 ? 0 : statistics.meanSectionScore[id] / statistics.maxSectionScore[id] * 100) + '%)');
						  });
						  
						  $(".statBestSectionScore").each(function(){
							  var id = $(this).attr("data-id");							  
							  $(this).html(roundToTwo(statistics.bestSectionScore[id]) + '&#x20;<spring:message code="label.of" />&#x20;' + statistics.maxSectionScore[id] + '&#x20;<spring:message code="label.points" /> (' + roundToTwo(statistics.maxSectionScore[id] == 0 ? 0 : statistics.bestSectionScore[id] / statistics.maxSectionScore[id] * 100) + '%)');

							  if (statistics.maxSectionScore[id] == 0) {
								  $(this).closest(".sectionwithratingquestions").hide();
							  }
						  });

						  $(".sectiontitle").each(function () {
							  var id = $(this).attr("data-id");
							  if (statistics.maxSectionScore[id] == 0) {
								  $(this).hide();
								  $(this).next().hide();
								  $(this).next().next().hide();
							  }
						  });

					  },
					error: function () {
						//this means the asynchronous computation has been started
						setTimeout(function () {
							loadStatisticsAsync(publication);
						}, 2000);
					}
				});
		}

		function roundToTwo(num) {
			return +(Math.round(num + "e+2") + "e-2");
		}

		function delphiPopulateAllGraphs(resultsStatisticParentElement) {
			var chartwrapperlist = $(resultsStatisticParentElement).find(".chart-wrapper");
			chartwrapperlist.each(function (index) {

				$(this).parent().find(".chart-controls").append($("#chart-controls-template").html());

				$(this).parent().find('[data-toggle="tooltip"]').tooltip();

				var chartwrapper = $(this);
				loadGraphDataInner(chartwrapper, addChart, null, 'tableau.Tableau10', null);
			});
		}

		function changeChart(select, updateLegendCheckbox) {
			var controls = $(select).closest(".chart-controls");		
			
			var chartwrapper = $(select).closest(".statelement-wrapper").find(".chart-wrapper").first();
			var chartType = $(controls).find(".chart-type").first().val();
			var scheme = $(controls).find(".chart-scheme").first().val();
			var legend = $(controls).find(".chart-legend").first().is(":checked");
			
			if (updateLegendCheckbox)
			{
				loadGraphDataInner(chartwrapper, addChart, chartType, scheme, null);
			} else {
				loadGraphDataInner(chartwrapper, addChart, chartType, scheme, legend);
			}			
		}

		function chartLabelCallback(value, index, values) {
			return value.length > 15 ? value.substring(0, 10) + "..." : value;
		}

		/**
		 * Labels may be returned with some HTML code. This method returns the text content without any markup or an empty string.
		 * @param {string} value
		 */
		function normalizeLabel(value) {
			var parser = new DOMParser();
			var doc = parser.parseFromString(value, "text/html");
			return doc.body.textContent || "";
		}

		/**
		 * Tries to nicely split a label into multiple lines for Chart.js
		 * @param value
		 * @param {number} lineLength - Maximum number of characters per line
		 * @returns {string | string[]}
		 */
		function wrapLabel(value, lineLength) {
			// try to coerce value into a string
			value = value == undefined ? "" : value.toString();

			// split by whitespace
			var words = value.trim().split(/\s+/g);

			if (words.length === 0) {
				// only whitespace
				return "";
			}

			var result = [];
			var currentLine = "";
			var i = 0;

			while (true) {
				var word = words[i];

				if (i >= words.length) {
					// out-of-bounds, add current line to result (if not empty) and stop
					if (currentLine) {
						result.push(currentLine);
					}

					break;
				}

				if (!currentLine) {
					if (word.length > lineLength) {
						// word is longer than allowed length => split word in between and create new line
						result.push(word.substr(0, lineLength));

						// remove first lineLength characters in word and try again
						words[i] = word.substr(lineLength);
						continue;
					}

					// set current line to current word and increase index
					currentLine = word;
					i++;
					continue;
				}

				if (currentLine.length + 1 + word.length <= lineLength) {
					// word fits in current line, separated by space character
					currentLine += " " + word;
					i++;
					continue;
				}

				// word does not fit into current line anymore => retry on current word with new line (index not increased)
				result.push(currentLine);
				currentLine = "";
			}

			if (result.length === 1) {
				// only one line => return as string
				return result[0];
			}

			// multiple lines => return as array
			return result;
		}

		function loadGraphDataInner(div, chartCallback, chartType, scheme, legend) {

			var surveyid = div.data("survey-id");
			var questionuid = div.data("question-uid");
			var languagecode = div.data("language-code");
			var uniquecode = ""; // not needed for privileged users like form managers

			var data = "surveyid=" + surveyid + "&questionuid=" + questionuid + "&languagecode=" + languagecode + "&uniquecode=" + uniquecode + "&resultsview=true";

			$.ajax({
				type: "GET",
				url: contextpath + "/runner/delphiGraph",
				data: data,
				beforeSend: function (xhr) {
					xhr.setRequestHeader(csrfheader, csrftoken);
				},
				error: function (data) {
					showError(data.responseText);
				},
				success: function (result, textStatus) {
					if (textStatus === "nocontent") {
						var elementWrapper = $(div).closest(".elementwrapper, .statelement-wrapper");
						$(elementWrapper).find(".delphi-chart").remove();
						$(elementWrapper).find(".chart-wrapper").hide();
						$(elementWrapper).find(".chart-controls").hide();

						return;
					}

					if (chartType == null) {
						chartType = result.chartType;
					}

					if (legend === null) {
						legend = result.questionType === "Matrix" || result.questionType === "Rating" || chartType === "Pie";
					}

					var chartData = {};
					var chartOptions = {
						scaleShowValues: true,
						responsive: false,
						scales: {
							yAxes: [{ticks: {beginAtZero: true, autoSkip: false, callback: chartLabelCallback}}],
							xAxes: [{ticks: {beginAtZero: true, autoSkip: false, callback: chartLabelCallback}}]
						},
						legend: {display: legend},
						animation: {
							onComplete: function (animation) {
								$(div).closest(".statelement-wrapper").find('.chart-download').attr('href', this.toBase64Image());
							}
						},
						plugins: {
							colorschemes: {
								scheme: scheme
							}
						}
					};

					switch (result.questionType) {
						case "MultipleChoice":
						case "SingleChoice":
							var graphData = result.data;

							chartData = {
								datasets: [{
									label: '',
									data: graphData.map(function (g) {
										return g.value
									})
								}],
								labels: graphData.map(function (g) {
									return normalizeLabel(g.label)
								})
							};
							break;

						case "Matrix":
						case "Rating":
							var questions = result.questions;
							var datasets = [];
							var labels = undefined;

							for (var i = 0; i < questions.length; i++) {
								var question = questions[i];

								datasets.push({
									data: question.data.map(function (d) {
										return d.value;
									}),
									label: normalizeLabel(question.label)
								});

								if (!labels) {
									labels = question.data.map(function (d) {
										return normalizeLabel(d.label);
									});
								}
							}

							chartData = {
								datasets,
								labels
							}

							break;

						default:
							return;
					}

					var chart = {
						data: chartData,
						options: chartOptions
					}

					switch (chartType) {
						case "Bar":
							chart.type = "horizontalBar";
							break;
						case "Column":
							chart.type = "bar";
							break;
						case "Line":
							chart.type = "line";
							break;
						case "Pie":
							chart.type = "pie";
							delete chart.options.scales;
							break;
						case "Radar":
							chart.type = "radar";
							delete chart.options.scales;
							chart.options.scale = {pointLabels: {callback: chartLabelCallback}};
							break;
						case "Scatter":
							chart.type = "line";
							chart.options.showLines = false;
							break;
						default:
							chart.type = "horizontalBar";
							break;
					}

					chart.options.tooltips = {
						callbacks: {
							title: chart.data.datasets.length === 1
									? function (item, data) {
										var label = chart.type === "radar" ? data.labels[item[0].index] : item[0].label;
										return wrapLabel(label, 30);
									} : function (item, data) {
										var label = chart.type === "pie" ? data.datasets[item[0].datasetIndex].label : data.labels[item[0].index];
										return wrapLabel(label, 30);
									},
							label: chart.data.datasets.length === 1
									? function (item, data) {
										var label = chart.type === "pie"
												? data.labels[item.index] + ": " + data.datasets[item.datasetIndex].data[item.index]
												: item.value;
										return wrapLabel(label, 30);
									} : function (item, data) {
										var label = chart.type === "pie"
												? data.labels[item.index] + ": " + data.datasets[item.datasetIndex].data[item.index]
												: data.datasets[item.datasetIndex].label + ": " + item.value;
										return wrapLabel(label, 30);
									}
						}
					}

					if (chartCallback instanceof Function) {
						chartCallback(div, chart, chartType, legend);
					}
				}
			});
		}

		function addChart(div, chart, chartType, legend) {
			var elementWrapper = $(div).closest(".elementwrapper, .statelement-wrapper");

			$(elementWrapper).find(".delphi-chart").remove();

			var size = $(elementWrapper).find(".chart-size").first().val();

			if (size === 'medium') {
				$(elementWrapper).find(".delphi-chart-div").append("<canvas class='delphi-chart' width='450' height='330' style='background-color: #fff;'></canvas>");
			} else if (size === 'large') {
				$(elementWrapper).find(".delphi-chart-div").append("<canvas class='delphi-chart' width='600' height='440' style='background-color: #fff;'></canvas>");
        	 } else {
        		$(elementWrapper).find(".delphi-chart-div").append("<canvas class='delphi-chart' width='300' height='220' style='background-color: #fff;'></canvas>");
  		 	 }        	 

        	$(elementWrapper).find(".chart-wrapper").show();
        	$(elementWrapper).find(".chart-controls").show();
        	
        	$(elementWrapper).find(".chart-type").each(function(){
        		$(this).val(chartType);
        	});
        	
        	if (legend) {
        		$(elementWrapper).find(".chart-legend-group").show();
        		$(elementWrapper).find(".chart-legend").prop("checked", "checked");
        	} else {
        		$(elementWrapper).find(".chart-legend-group").hide();
        		$(elementWrapper).find(".chart-legend").removeAttr("checked");
        	}
        
        	var graph = new Chart($(elementWrapper).find(".delphi-chart")[0].getContext('2d'), chart);
        }

	</script>
</c:if>