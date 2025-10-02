package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"
)

// CoverageReport represents test coverage data
type CoverageReport struct {
	Timestamp       time.Time           `json:"timestamp"`
	TotalCoverage   float64            `json:"total_coverage"`
	PackageCoverage map[string]float64  `json:"package_coverage"`
	FileCoverage    map[string]FileCov  `json:"file_coverage"`
	UncoveredFuncs  []string           `json:"uncovered_functions"`
	TestCount       int                `json:"test_count"`
	PassCount       int                `json:"pass_count"`
	FailCount       int                `json:"fail_count"`
}

// FileCov represents coverage for a single file
type FileCov struct {
	Path      string  `json:"path"`
	Coverage  float64 `json:"coverage"`
	Lines     int     `json:"lines"`
	Covered   int     `json:"covered"`
	Uncovered int     `json:"uncovered"`
}

// CoverageMonitor monitors and reports test coverage
type CoverageMonitor struct {
	ProjectPath  string
	ReportPath   string
	HistoryPath  string
}

// RunCoverage executes go test with coverage and parses results
func (cm *CoverageMonitor) RunCoverage() (*CoverageReport, error) {
	report := &CoverageReport{
		Timestamp:       time.Now(),
		PackageCoverage: make(map[string]float64),
		FileCoverage:    make(map[string]FileCov),
		UncoveredFuncs:  []string{},
	}

	// Run tests with coverage
	fmt.Println("Running tests with coverage...")
	cmd := exec.Command("go", "test", "-mod=readonly", "-cover", "-coverprofile=coverage.out", "./catalystcenter/...")
	output, err := cmd.CombinedOutput()
	if err != nil {
		// Tests may fail but we still want coverage data
		fmt.Printf("Test execution had issues: %v\n", err)
	}

	// Parse test results
	testOutput := string(output)
	report.TestCount = strings.Count(testOutput, "=== RUN")
	report.PassCount = strings.Count(testOutput, "--- PASS")
	report.FailCount = strings.Count(testOutput, "--- FAIL")

	// Parse coverage report
	if _, err := os.Stat("coverage.out"); err == nil {
		// Get detailed coverage
		cmd = exec.Command("go", "tool", "cover", "-func=coverage.out")
		output, err = cmd.Output()
		if err != nil {
			return nil, fmt.Errorf("failed to parse coverage: %v", err)
		}

		lines := strings.Split(string(output), "\n")
		for _, line := range lines {
			if line == "" {
				continue
			}

			// Parse coverage line
			parts := strings.Fields(line)
			if len(parts) >= 3 {
				// Extract file, function, and coverage
				if strings.HasPrefix(parts[0], "terraform-provider-catalystcenter/") {
					file := strings.TrimPrefix(parts[0], "terraform-provider-catalystcenter/")

					// Parse coverage percentage
					covStr := parts[len(parts)-1]
					if strings.HasSuffix(covStr, "%") {
						covStr = strings.TrimSuffix(covStr, "%")
						if cov, err := strconv.ParseFloat(covStr, 64); err == nil {
							// Check if this is the total line
							if parts[len(parts)-2] == "total:" {
								report.TotalCoverage = cov
							} else {
								// Track file coverage
								if _, exists := report.FileCoverage[file]; !exists {
									report.FileCoverage[file] = FileCov{
										Path:     file,
										Coverage: cov,
									}
								}

								// Track uncovered functions
								if cov == 0 {
									funcName := fmt.Sprintf("%s:%s", file, parts[1])
									report.UncoveredFuncs = append(report.UncoveredFuncs, funcName)
								}
							}
						}
					}
				}
			}
		}
	}

	return report, nil
}

// GenerateHTMLReport creates an HTML dashboard for coverage
func (cm *CoverageMonitor) GenerateHTMLReport(report *CoverageReport) error {
	html := `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catalyst Center Provider - Coverage Dashboard</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 {
            color: #333;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
        }
        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        .metric {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            border-left: 4px solid #667eea;
        }
        .metric-value {
            font-size: 2.5em;
            font-weight: bold;
            color: #333;
        }
        .metric-label {
            color: #666;
            margin-top: 5px;
        }
        .coverage-bar {
            width: 100%;
            height: 30px;
            background: #e9ecef;
            border-radius: 15px;
            overflow: hidden;
            margin: 20px 0;
        }
        .coverage-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            transition: width 1s ease;
        }
        .file-list {
            margin-top: 30px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #dee2e6;
        }
        th {
            background: #f8f9fa;
            font-weight: 600;
            color: #495057;
        }
        tr:hover {
            background: #f8f9fa;
        }
        .low-coverage {
            color: #dc3545;
            font-weight: bold;
        }
        .medium-coverage {
            color: #ffc107;
            font-weight: bold;
        }
        .high-coverage {
            color: #28a745;
            font-weight: bold;
        }
        .timestamp {
            color: #6c757d;
            font-size: 0.9em;
            margin-top: 20px;
        }
        .chart-container {
            margin: 30px 0;
            height: 300px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Catalyst Center Provider - Test Coverage Dashboard</h1>

        <div class="coverage-bar">
            <div class="coverage-fill" style="width: {{ .TotalCoverage }}%">
                {{ printf "%.1f" .TotalCoverage }}% Coverage
            </div>
        </div>

        <div class="metrics">
            <div class="metric">
                <div class="metric-value">{{ printf "%.1f" .TotalCoverage }}%</div>
                <div class="metric-label">Total Coverage</div>
            </div>
            <div class="metric">
                <div class="metric-value">{{ .TestCount }}</div>
                <div class="metric-label">Total Tests</div>
            </div>
            <div class="metric">
                <div class="metric-value">{{ .PassCount }}</div>
                <div class="metric-label">Passing</div>
            </div>
            <div class="metric">
                <div class="metric-value">{{ .FailCount }}</div>
                <div class="metric-label">Failing</div>
            </div>
            <div class="metric">
                <div class="metric-value">{{ len .FileCoverage }}</div>
                <div class="metric-label">Files Tested</div>
            </div>
            <div class="metric">
                <div class="metric-value">{{ len .UncoveredFuncs }}</div>
                <div class="metric-label">Uncovered Functions</div>
            </div>
        </div>

        <h2>📊 Coverage by File</h2>
        <div class="file-list">
            <table>
                <thead>
                    <tr>
                        <th>File</th>
                        <th>Coverage</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    {{ range $path, $cov := .FileCoverage }}
                    <tr>
                        <td>{{ $path }}</td>
                        <td class="{{ if lt $cov.Coverage 30.0 }}low-coverage{{ else if lt $cov.Coverage 70.0 }}medium-coverage{{ else }}high-coverage{{ end }}">
                            {{ printf "%.1f" $cov.Coverage }}%
                        </td>
                        <td>
                            {{ if lt $cov.Coverage 30.0 }}❌ Needs Improvement
                            {{ else if lt $cov.Coverage 70.0 }}⚠️ Fair
                            {{ else }}✅ Good{{ end }}
                        </td>
                    </tr>
                    {{ end }}
                </tbody>
            </table>
        </div>

        <div class="timestamp">
            Generated: {{ .Timestamp.Format "2006-01-02 15:04:05 MST" }}
        </div>
    </div>
</body>
</html>`

	// Simple template replacement (in production, use html/template)
	htmlContent := strings.ReplaceAll(html, "{{ .TotalCoverage }}", fmt.Sprintf("%.1f", report.TotalCoverage))
	htmlContent = strings.ReplaceAll(htmlContent, "{{ printf \"%.1f\" .TotalCoverage }}", fmt.Sprintf("%.1f", report.TotalCoverage))
	htmlContent = strings.ReplaceAll(htmlContent, "{{ .TestCount }}", strconv.Itoa(report.TestCount))
	htmlContent = strings.ReplaceAll(htmlContent, "{{ .PassCount }}", strconv.Itoa(report.PassCount))
	htmlContent = strings.ReplaceAll(htmlContent, "{{ .FailCount }}", strconv.Itoa(report.FailCount))
	htmlContent = strings.ReplaceAll(htmlContent, "{{ len .FileCoverage }}", strconv.Itoa(len(report.FileCoverage)))
	htmlContent = strings.ReplaceAll(htmlContent, "{{ len .UncoveredFuncs }}", strconv.Itoa(len(report.UncoveredFuncs)))
	htmlContent = strings.ReplaceAll(htmlContent, "{{ .Timestamp.Format \"2006-01-02 15:04:05 MST\" }}",
		report.Timestamp.Format("2006-01-02 15:04:05 MST"))

	// Create file table rows
	var fileRows []string
	for path, cov := range report.FileCoverage {
		class := "high-coverage"
		status := "✅ Good"
		if cov.Coverage < 30.0 {
			class = "low-coverage"
			status = "❌ Needs Improvement"
		} else if cov.Coverage < 70.0 {
			class = "medium-coverage"
			status = "⚠️ Fair"
		}

		row := fmt.Sprintf(`
                    <tr>
                        <td>%s</td>
                        <td class="%s">%.1f%%</td>
                        <td>%s</td>
                    </tr>`, path, class, cov.Coverage, status)
		fileRows = append(fileRows, row)
	}

	// Replace file rows
	fileRowsHTML := strings.Join(fileRows, "\n")
	htmlContent = regexp.MustCompile(`{{ range.*?{{ end }}`).ReplaceAllString(htmlContent, fileRowsHTML)

	// Write HTML file
	htmlPath := filepath.Join(cm.ReportPath, "coverage_dashboard.html")
	err := ioutil.WriteFile(htmlPath, []byte(htmlContent), 0644)
	if err != nil {
		return fmt.Errorf("failed to write HTML report: %v", err)
	}

	fmt.Printf("Generated HTML dashboard: %s\n", htmlPath)
	return nil
}

// SaveHistory saves coverage report to history
func (cm *CoverageMonitor) SaveHistory(report *CoverageReport) error {
	// Create history directory if it doesn't exist
	if err := os.MkdirAll(cm.HistoryPath, 0755); err != nil {
		return fmt.Errorf("failed to create history directory: %v", err)
	}

	// Save JSON report
	timestamp := report.Timestamp.Format("2006-01-02_15-04-05")
	jsonPath := filepath.Join(cm.HistoryPath, fmt.Sprintf("coverage_%s.json", timestamp))

	data, err := json.MarshalIndent(report, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal report: %v", err)
	}

	err = ioutil.WriteFile(jsonPath, data, 0644)
	if err != nil {
		return fmt.Errorf("failed to write history: %v", err)
	}

	fmt.Printf("Saved coverage history: %s\n", jsonPath)
	return nil
}

// GenerateTrendReport creates a trend analysis from history
func (cm *CoverageMonitor) GenerateTrendReport() error {
	// Read all history files
	files, err := filepath.Glob(filepath.Join(cm.HistoryPath, "coverage_*.json"))
	if err != nil {
		return fmt.Errorf("failed to read history: %v", err)
	}

	sort.Strings(files)

	var reports []CoverageReport
	for _, file := range files {
		data, err := ioutil.ReadFile(file)
		if err != nil {
			continue
		}

		var report CoverageReport
		if err := json.Unmarshal(data, &report); err != nil {
			continue
		}

		reports = append(reports, report)
	}

	// Generate trend markdown
	trendPath := filepath.Join(cm.ReportPath, "coverage_trend.md")
	trend := fmt.Sprintf(`# Coverage Trend Analysis

## Coverage History

| Date | Coverage | Tests | Pass | Fail | Trend |
|------|----------|-------|------|------|-------|
`)

	prevCoverage := 0.0
	for i, report := range reports {
		trend := "➡️"
		if i > 0 {
			if report.TotalCoverage > prevCoverage {
				trend = "📈"
			} else if report.TotalCoverage < prevCoverage {
				trend = "📉"
			}
		}
		prevCoverage = report.TotalCoverage

		trend += fmt.Sprintf("| %s | %.1f%% | %d | %d | %d | %s |\n",
			report.Timestamp.Format("2006-01-02"),
			report.TotalCoverage,
			report.TestCount,
			report.PassCount,
			report.FailCount,
			trend)
	}

	err = ioutil.WriteFile(trendPath, []byte(trend), 0644)
	if err != nil {
		return fmt.Errorf("failed to write trend report: %v", err)
	}

	fmt.Printf("Generated trend report: %s\n", trendPath)
	return nil
}

func main() {
	monitor := &CoverageMonitor{
		ProjectPath: ".",
		ReportPath:  "./coverage_reports",
		HistoryPath: "./coverage_reports/history",
	}

	// Create report directory
	if err := os.MkdirAll(monitor.ReportPath, 0755); err != nil {
		fmt.Printf("Failed to create report directory: %v\n", err)
		os.Exit(1)
	}

	// Run coverage
	fmt.Println("Starting coverage analysis...")
	report, err := monitor.RunCoverage()
	if err != nil {
		fmt.Printf("Failed to run coverage: %v\n", err)
		os.Exit(1)
	}

	// Generate HTML dashboard
	err = monitor.GenerateHTMLReport(report)
	if err != nil {
		fmt.Printf("Failed to generate HTML report: %v\n", err)
	}

	// Save to history
	err = monitor.SaveHistory(report)
	if err != nil {
		fmt.Printf("Failed to save history: %v\n", err)
	}

	// Generate trend report
	err = monitor.GenerateTrendReport()
	if err != nil {
		fmt.Printf("Failed to generate trend report: %v\n", err)
	}

	// Print summary
	fmt.Println("\n=== Coverage Summary ===")
	fmt.Printf("Total Coverage: %.1f%%\n", report.TotalCoverage)
	fmt.Printf("Tests: %d (Pass: %d, Fail: %d)\n", report.TestCount, report.PassCount, report.FailCount)
	fmt.Printf("Files Tested: %d\n", len(report.FileCoverage))
	fmt.Printf("Uncovered Functions: %d\n", len(report.UncoveredFuncs))
	fmt.Println("\nReports generated in ./coverage_reports/")
}