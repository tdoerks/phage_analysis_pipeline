process COMBINE_RESULTS {
    publishDir "${params.outdir}/summary", mode: 'copy'
    
    input:
    path vibrant_results
    path diamond_results
    path checkv_results
    
    output:
    path "phage_analysis_summary.tsv", emit: summary
    path "phage_analysis_report.html", emit: report
    path "versions.yml", emit: versions
    
    script:
    """
    #!/usr/bin/env python3
    
    import pandas as pd
    import glob
    import os
    from pathlib import Path
    
    # Initialize summary data
    summary_data = []
    
    # Process VIBRANT results
    vibrant_files = glob.glob("*_vibrant/VIBRANT_*/VIBRANT_results_*/VIBRANT_summary_*.tsv")
    for vf in vibrant_files:
        sample_id = Path(vf).parts[0].replace('_vibrant', '')
        if os.path.exists(vf):
            df = pd.read_csv(vf, sep='\\t')
            summary_data.append({
                'sample_id': sample_id,
                'vibrant_phages': len(df),
                'vibrant_file': vf
            })
    
    # Process DIAMOND results
    diamond_files = glob.glob("*_prophage_hits.tsv")
    diamond_data = {}
    for df_file in diamond_files:
        sample_id = Path(df_file).stem.replace('_prophage_hits', '')
        if os.path.exists(df_file) and os.path.getsize(df_file) > 0:
            df = pd.read_csv(df_file, sep='\\t', header=None)
            diamond_data[sample_id] = len(df)
    
    # Process CheckV results
    checkv_files = glob.glob("*_checkv/quality_summary.tsv")
    checkv_data = {}
    for cv_file in checkv_files:
        sample_id = Path(cv_file).parts[0].replace('_checkv', '')
        if os.path.exists(cv_file):
            df = pd.read_csv(cv_file, sep='\\t')
            checkv_data[sample_id] = {
                'high_quality': len(df[df['checkv_quality'] == 'High-quality']),
                'medium_quality': len(df[df['checkv_quality'] == 'Medium-quality']),
                'low_quality': len(df[df['checkv_quality'] == 'Low-quality'])
            }
    
    # Combine all results
    final_summary = []
    all_samples = set()
    
    for item in summary_data:
        all_samples.add(item['sample_id'])
    all_samples.update(diamond_data.keys())
    all_samples.update(checkv_data.keys())
    
    for sample in all_samples:
        row = {'sample_id': sample}
        
        # Add VIBRANT data
        vibrant_info = next((item for item in summary_data if item['sample_id'] == sample), {})
        row['vibrant_phages'] = vibrant_info.get('vibrant_phages', 0)
        
        # Add DIAMOND data
        row['prophage_hits'] = diamond_data.get(sample, 0)
        
        # Add CheckV data
        checkv_info = checkv_data.get(sample, {})
        row['high_quality_phages'] = checkv_info.get('high_quality', 0)
        row['medium_quality_phages'] = checkv_info.get('medium_quality', 0)
        row['low_quality_phages'] = checkv_info.get('low_quality', 0)
        
        final_summary.append(row)
    
    # Create summary DataFrame and save
    summary_df = pd.DataFrame(final_summary)
    summary_df.to_csv('phage_analysis_summary.tsv', sep='\\t', index=False)
    
    # Create HTML report
    html_report = f'''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Phage Analysis Summary Report</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 40px; }}
            table {{ border-collapse: collapse; width: 100%; }}
            th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
            th {{ background-color: #f2f2f2; }}
            .summary {{ background-color: #e7f3ff; padding: 20px; margin: 20px 0; }}
        </style>
    </head>
    <body>
        <h1>Phage Analysis Summary Report</h1>
        
        <div class="summary">
            <h2>Analysis Overview</h2>
            <p><strong>Total Samples Analyzed:</strong> {len(summary_df)}</p>
            <p><strong>Total Phages Identified (VIBRANT):</strong> {summary_df['vibrant_phages'].sum()}</p>
            <p><strong>Total Prophage Hits (DIAMOND):</strong> {summary_df['prophage_hits'].sum()}</p>
            <p><strong>High Quality Phages (CheckV):</strong> {summary_df['high_quality_phages'].sum()}</p>
        </div>
        
        <h2>Detailed Results</h2>
        {summary_df.to_html(index=False, table_id="results_table")}
        
        <h2>Analysis Tools Used</h2>
        <ul>
            <li><strong>VIBRANT:</strong> Phage identification and annotation</li>
            <li><strong>DIAMOND + Prophage-DB:</strong> Homology-based prophage detection</li>
            <li><strong>CheckV:</strong> Phage quality assessment</li>
            <li><strong>PHANOTATE:</strong> Gene prediction for phages</li>
        </ul>
    </body>
    </html>
    '''
    
    with open('phage_analysis_report.html', 'w') as f:
        f.write(html_report)
    
    # Create versions file
    with open('versions.yml', 'w') as f:
        f.write(f'''"{os.environ.get('task_process', 'COMBINE_RESULTS')}":
    python: "3.8+"
    pandas: "1.5.3"
''')
    """
    
    stub:
    """
    touch phage_analysis_summary.tsv
    touch phage_analysis_report.html
    touch versions.yml
    """
}